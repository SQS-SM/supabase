import 'https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

const AUTHORIZATION_HEADER: string = 'Authorization';
const GET_CLIENT_QUOTE_FUNCTION_NAME: string = 'get_active_errands';
const CONTENT_TYPE: string = 'application/json';
const VALIDATION_ERROR_CODE: string = '22400';

function supabase(authorizationToken: string) {
	const url = Deno.env.get('SUPABASE_URL') ?? '';
	const key = Deno.env.get('SUPABASE_ANON_KEY') ?? '';

	return createClient(url, key, {
		global: { headers: { Authorization: authorizationToken! } }
	});
}

function createResponse(data: any, statusCode: number): Response {
	return new Response(JSON.stringify(data), {
		headers: {
			'Content-Type': CONTENT_TYPE
		},
		status: statusCode
	});
}

function handleError(error: any): Response {
	const isBusinessValidationError: boolean = VALIDATION_ERROR_CODE === error.code;
	const statusCode: number = isBusinessValidationError ? 400 : 500;
	const errorCode: string = isBusinessValidationError ? '422' : '500';
	const errorMessage: string = String(error?.message ?? error);

	return createResponse(
		{
			message: errorMessage,
			code: errorCode
		},
		statusCode
	);
}

Deno.serve(async request => {
	try {
		const { data, error } = await supabase(request.headers.get(AUTHORIZATION_HEADER)).rpc(
			GET_CLIENT_QUOTE_FUNCTION_NAME
		);

		if (error) {
			throw error;
		}

		return createResponse(data, 200);
	} catch (error) {
		return handleError(error);
	}
});
