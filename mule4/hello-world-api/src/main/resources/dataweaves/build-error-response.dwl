%dw 2.0
output application/json
---
error: {
	errorCode: if(vars.errorCode != null) vars.errorCode else error.errorType.identifier,
	errorDateTime: now() as String { format: "yyyy-MM-dd'T'HH:mm:ss" },
	errorMessage: if(vars.errorMessage != null) vars.errorMessage else 'Undefined error message. Please, improve your error handling!',
	errorDescription: 'Description: ' ++ (error.description default "")
}