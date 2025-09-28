﻿using AutoWrapper.Wrappers;
using Microsoft.AspNetCore.Http;

namespace DomainLayer.Exceptions;

public class BadRequestException : BaseHttpException
{
    private readonly static int statusCode = StatusCodes.Status400BadRequest;

    public BadRequestException(object customError) : base(customError, statusCode)
    {
    }

    public BadRequestException(IEnumerable<ValidationError> errors) : base(errors, statusCode)
    {
    }

    public BadRequestException(Exception ex) : base(ex, statusCode)
    {
    }

    public BadRequestException(string message = "Bad Request", string errorCode = null, string refLink = null) : base(message, statusCode, errorCode, refLink)
    {
    }
}
