import "https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";

const AUTHORIZATION_HEADER: string = "Authorization";
const DELETE_ERRAND_FUNCTION_NAME: string = "delete_errand";
const CONTENT_TYPE: string = "application/json";
const VALIDATION_ERROR_CODE: string = "22400";
const ERRAND_MEDIA_BUCKET: string = "errand_media";

function supabase(authorizationToken: string) {
	const url = Deno.env.get("SUPABASE_URL") ?? "";
	const key = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

	return createClient(url, key, {
		global: { headers: { Authorization: authorizationToken! } },
	});
}

function createResponse(data: any, statusCode: number): Response {
	return new Response(JSON.stringify(data), {
		headers: {
			"Content-Type": CONTENT_TYPE,
		},
		status: statusCode,
	});
}

function handleError(error: any): Response {
	const isBusinessValidationError: boolean = VALIDATION_ERROR_CODE === error.code;
	const statusCode: number = isBusinessValidationError ? 400 : 500;
	const errorCode: string = isBusinessValidationError ? "422" : "500";
	const errorMessage: string = String(error?.message ?? error);

	return createResponse(
		{
			message: errorMessage,
			code: errorCode,
		},
		statusCode
	);
}

async function deleteErrandAttachments(attachments: any, request) {
	const { data, error } = await supabase(request.headers.get(AUTHORIZATION_HEADER))
		.storage.from(ERRAND_MEDIA_BUCKET)
		.remove(attachments.map((a) => a.file_name));

	if (error) {
		throw error;
	}

	return data;
}

Deno.serve(async (request) => {
	try {
		const { errandId } = await request.json();
		const { data, error } = await supabase(request.headers.get(AUTHORIZATION_HEADER)).rpc(DELETE_ERRAND_FUNCTION_NAME, {
			client_errand_id: errandId,
		});

		if (error) {
			throw error;
		}

		await deleteErrandAttachments(data, request);

		return createResponse(
			{
				message: "Errand successfully deleted.",
				code: "0000",
			},
			200
		);
	} catch (error) {
		return handleError(error);
	}
});
