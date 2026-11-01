import {
  ArgumentsHost,
  CallHandler,
  Catch,
  ExceptionFilter,
  ExecutionContext,
  HttpException,
  HttpStatus,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import type { Response } from 'express';
import { map, Observable } from 'rxjs';

/** 成功响应统一为 `{ data }`。 */
@Injectable()
export class ResponseInterceptor implements NestInterceptor {
  intercept(_: ExecutionContext, next: CallHandler): Observable<unknown> {
    return next.handle().pipe(map((data: unknown) => ({ data: data ?? null })));
  }
}

/** 错误响应统一为 `{ error: { code, message } }`，code 与 HTTP 状态码一致。 */
@Catch()
export class HttpErrorFilter implements ExceptionFilter {
  private readonly logger = new Logger(HttpErrorFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const res = host.switchToHttp().getResponse<Response>();
    if (exception instanceof HttpException) {
      const status = exception.getStatus();
      const body = exception.getResponse();
      const raw =
        typeof body === 'string'
          ? body
          : (body as { message?: string | string[] }).message;
      const message = Array.isArray(raw) ? raw.join('；') : raw;
      res
        .status(status)
        .json({ error: { code: status, message: message ?? exception.message } });
      return;
    }
    this.logger.error(exception);
    res.status(HttpStatus.INTERNAL_SERVER_ERROR).json({
      error: { code: HttpStatus.INTERNAL_SERVER_ERROR, message: '服务器内部错误' },
    });
  }
}
