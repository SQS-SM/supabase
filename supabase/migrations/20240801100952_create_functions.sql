drop function if exists public.accept_quote;

create or replace function public.accept_quote(client_quote_id integer)
returns setof public.errand as $$
	declare
		auth_token jsonb;
		client_id text;
		runner_id text;
		client_errand_id int;
	begin

		select auth.jwt() into auth_token;	

		if auth_token is null then
			raise exception 'Error occurred, you must be logged in to accept the quote.' using errcode = '22400';
		end if;

		select auth_token ->> 'sub' into client_id;

		if client_id is null then
			raise exception 'Error occurred, invalid authentication method.' using errcode = '22400';
		end if;

		if not exists(select 1
					  from public.quote q
					  where q.id = client_quote_id) then
			raise exception 'Error occurred, the quote you are trying to accept does not exist.' using errcode = '22400';
		end if;

		select q.errand_id into client_errand_id
		from public.quote q
		where q.id = client_quote_id;

		if not exists(select 1
					  from public.errand e
					  where e.id = client_errand_id
					    and e.client_account_id = client_id) then
			raise exception 'Error occurred, account id not found.' using errcode = '22400';
		end if;

		select q.runner_account_id into runner_id
		from public.quote q
		where q.id = client_quote_id;
	
		update public.errand e
		set status = 'quote_accepted',
			status_updated_time = current_timestamp
		where e.id = client_errand_id;

		delete from public.quote q 
		where q.errand_id = client_errand_id
			and q.id != client_quote_id;

		delete from public.quote q
		where q.runner_account_id = runner_id
			and q.id != client_quote_id;
		
		return query select e.*
					 from public.errand e
					 where e.id = client_errand_id;

	end; 
$$ language plpgsql;

grant execute on function public.accept_quote to authenticated;

drop function if exists public.get_client_quotes;

create or replace function public.get_client_quotes(client_errand_id integer)

returns setof public."quote" as $$
	declare
		auth_token jsonb;
		client_id text;
	begin

		select auth.jwt() into auth_token;

		if auth_token is null then
			raise exception 'Error occurred, you must be logged in to retrieve the quotes.' using ERRCODE = '22400';
		end if;

		select auth_token ->>'sub'into client_id;

		if client_id is null then
			raise exception 'Error occurred, invalid authentication method.' using ERRCODE = '22400';
		end if;


		if not exists(select *
					FROM public.errand e
					where e.id = client_errand_id
						and e.client_account_id = client_id) then
			raise exception 'Error occurred, account id is not found.' using ERRCODE = '22400';
		end if;

		return query select q.*
					 from public."quote" q
					 where q.errand_id = client_errand_id
					 order by q."cost" asc
					 limit 3;

	end;
$$ language plpgsql;

grant execute on function public.get_client_quotes to authenticated;

drop function if exists public.delete_errand;

create or replace function public.delete_errand(client_errand_id integer)
returns TABLE(file_name varchar(256)) as $$
	declare
		auth_token jsonb;
		client_id text;
		client_role_id int;
	begin
   
		select auth.jwt() into auth_token;

		if auth_token is null then
			raise exception 'Error occurred, you must be logged in to execute delete errand.' using ERRCODE = '22400';
		end if;

		select auth_token ->>'sub'into client_id;

		if client_id is null then
			raise exception 'Error occurred, invalid authentication method.' using ERRCODE = '22400';
		end if;

        if not exists(select * from public.account_information i where i.account_id = client_id and i.user_role_id = 3) then
            if not exists(select * from public.errand e where e.id = client_errand_id and e.client_account_id = client_id) then
                raise exception 'Error occurred, account id does not have rights to delete this errand.' using ERRCODE = '22400';
            end if;
        end if;

		create temp table if not exists temp_errand_files as
        select o.file_name
		from public.metadata o
		where o.errand_id = client_errand_id;

		delete from public.errand e
            where e.id = client_errand_id;
                    	
        return query select *
					 from temp_errand_files o;
					    

	end;
$$ language plpgsql;

grant execute on function public.delete_errand to authenticated;

drop function if exists public.get_active_errands;

create or replace function public.get_active_errands()
returns setof public.errand as $$
	declare
		auth_token jsonb;
		client_id text;
	begin
   
		select auth.jwt() into auth_token;

		if auth_token is null then
			raise exception 'Error occurred, you must be logged in to see a list of active errands.' using ERRCODE = '22400';
		end if;

		select auth_token ->>'sub'into client_id;

		if client_id is null then
			raise exception 'Error occurred, invalid authentication method.' using ERRCODE = '22400';
		end if;

        if not exists(select * from public.account_information i where i.account_id = client_id and i.user_role_id = 2) then
                raise exception 'Error occurred, account id does not have rights to see active errands.' using ERRCODE = '22400';
        end if;
       
		RETURN QUERY
    	SELECT e.*
    	FROM public.errand e
    	JOIN public.quote q ON e.id = q.errand_id
    	WHERE e.status IN ('quote_accepted', 'in_progress', 'pending_completed')
    	AND q.runner_account_id = client_id;
		
	end;
$$ language plpgsql;

grant execute on function public.get_active_errands to authenticated;

drop function if exists public.update_errand_status;

create or replace function public.update_errand_status(client_errand_id integer)
returns setof public.errand as $$
	declare
		auth_token jsonb;
		client_id text;
	begin
   
		select auth.jwt() into auth_token;

		if auth_token is null then
			raise exception 'Error occurred, you must be logged in to see updated errands.' using ERRCODE = '22400';
		end if;

		select auth_token ->>'sub'into client_id;

		if client_id is null then
			raise exception 'Error occurred, invalid authentication method.' using ERRCODE = '22400';
		end if;

        if not exists(select * from public.account_information i where i.account_id = client_id and i.user_role_id = 2) then
                raise exception 'Error occurred, account id does not have rights to see updated errands.' using ERRCODE = '22400';
        end if;
       
		update public.errand e
		set status = 'in_progress',
			status_updated_time = current_timestamp
		where
		e.status = 'quote_accepted'
		and
		e.id = client_errand_id;
		
 		update public.errand e
		set status = 'pending_completed',
			status_updated_time = current_timestamp
		where
		e.status = 'in_progress'
		and
		e.id = client_errand_id;

		return query select e.*
					 from public.errand e
					 where e.id = client_errand_id;
		
	end;
$$ language plpgsql;
grant execute on function public.update_errand_status to authenticated;
