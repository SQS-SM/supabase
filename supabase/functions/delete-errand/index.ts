import 'https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts';
import { createClient } from 'jsr:@supabase/supabase-js@2';

const AUTHORIZATION_HEADER: string = 'Authorization';
const DELETE_ERRAND_FUNCTION_NAME: string = 'delete_errand';
const CONTENT_TYPE: string = 'application/json';
const VALIDATION_ERROR_CODE: string = '22400';
const ERRAND_MEDIA_BUCKET: string = 'errand_media';

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

async function handleError(error: any): Promise<Response> {
	const isBusinessValidationError: boolean = VALIDATION_ERROR_CODE === error.code;
	const statusCode: number = isBusinessValidationError ? 400 : 500;
	const errorCode: string = isBusinessValidationError ? '422' : '500';
    let errorMessage: string;

    if (error instanceof Response) {
        errorMessage = await error.json(); 
    } else {
        // Handle other error types
        errorMessage = String(error?.message ?? error);
    }

	return createResponse(
		{
			message: errorMessage,
			code: errorCode
		},
		statusCode
	);
}

async function deleteErrandAttachments(attachments: { file_name: string }[], authHeader: string) {
	if (attachments.length === 0) {
		return [];
	}
	const { data, error } = await supabase(authHeader)
		.storage.from(ERRAND_MEDIA_BUCKET)
		.remove(attachments.map(a => a.file_name));

	if (error) {
		throw error;
	}

	return data;
}

async function deleteAsync(authHeader: string, client_errandId: string) {
	const { data: fileList, error: deleteError } = await supabase(authHeader).rpc(
		DELETE_ERRAND_FUNCTION_NAME,
		{
			client_errand_id: client_errandId
		}
	);

	if (deleteError) {
        console.log('#', deleteError)

		return handleError(deleteError);
	}

	await deleteErrandAttachments(fileList, authHeader);
}

async function deletePerRole(request, client_id: string, client_errandId: string) {
	const authHeader = request.headers.get(AUTHORIZATION_HEADER);

	const { data: roleId, error: roleError } = await supabase(authHeader)
		.from('account_information')
		.select('user_role_id')
		.eq('account_id', client_id)
		.single();

	if (roleError) {
		throw createResponse('Error fetching client role.', 500);
	}

	if (!roleId) {
		throw createResponse('Client role not found.', 404);
	}

	const { data: errand, error: errandError } = await supabase(authHeader)
		.from('errand')
		.select('*')
		.eq('id', client_errandId)
		.single();

	if (errandError) {
		throw createResponse('Error fetching errand', 500);
	}

	if (!errand) {
		throw createResponse('Errand not found.', 404);
	}

	if (errand.status === 'disputed') {
		if (roleId.user_role_id === 3) {
			deleteAsync(authHeader, client_errandId);
		} else {
			throw createResponse('Client role is not allowed to delete disputed errand.', 401);
		}
	} else {
		deleteAsync(authHeader, client_errandId);
	}
}

Deno.serve(async request => {
	try {
		const { errandId, clientId } = await request.json();

		if (!errandId || !clientId) {
			return createResponse('Client ID and Errand ID are required.', 400);
		}

		await deletePerRole(request, clientId, errandId);

		return createResponse(
			{
				message: 'Errand successfully deleted.',
				code: 200
			},
			200
		);
	} catch (error) {
		return handleError(error);
        
	}
});
