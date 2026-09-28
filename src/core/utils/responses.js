const sendResponse = (
  res,
  {
    success = true,
    status = 200,
    message = "Operação realizada com sucesso!",
    error = "",
    data = null,
    quant = null,
  } = {},
) => {
  return res.status(status).json({
    success,
    status,
    message,
    error,
    data,
    quant: Array.isArray(data) ? data.length : (quant ?? (data ? 1 : 0)),
  });
};

export const success = (
  res,
  { message = "Operação realizada com sucesso", data } = {},
) => {
  return sendResponse(res, { success: true, status: 200, message, data });
};

export const created = (
  res,
  { message = "Recurso criado com sucesso", data } = {},
) => {
  return sendResponse(res, { success: true, status: 201, message, data });
};

export const notFound = (res, { message = "Recurso não encontrado" } = {}) => {
  return sendResponse(res, { success: false, status: 404, message });
};

export const badRequest = (res, { message = "Requisição inválida" } = {}) => {
  return sendResponse(res, { success: false, status: 400, message });
};

export const unauthorized = (res, { message = "Não autorizado" } = {}) => {
  return sendResponse(res, { success: false, status: 401, message });
};

export const error = (
  res,
  {
    status = 500,
    message = "Erro interno do servidor",
    error: errorMsg,
    data,
  } = {},
) => {
  return sendResponse(res, {
    success: false,
    status,
    message,
    error: errorMsg ?? message,
    data,
  });
};