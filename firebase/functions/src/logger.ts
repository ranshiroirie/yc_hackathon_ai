type LogLevel = 'DEBUG' | 'INFO' | 'WARN' | 'ERROR';

export type LogContext = Record<string, unknown>;

const serviceName = process.env.K_SERVICE ?? 'hackathon-functions';

function sanitizeContext(context: LogContext | undefined): LogContext | undefined {
  if (!context) return undefined;
  const entries = Object.entries(context)
    .filter(([, value]) => value !== undefined)
    .map(([key, value]) => {
      if (value instanceof Error) {
        return [key, formatError(value)];
      }
      return [key, value];
    });
  return entries.length > 0 ? Object.fromEntries(entries) : undefined;
}

function formatError(error: Error | { message: string; name?: string; stack?: string }): LogContext {
  return {
    name: error.name ?? 'Error',
    message: error.message,
    stack: error.stack,
  };
}

function output(level: LogLevel, message: string, context?: LogContext): void {
  const logEntry: LogContext = {
    timestamp: new Date().toISOString(),
    level,
    service: serviceName,
    message,
  };

  const sanitized = sanitizeContext(context);
  if (sanitized) {
    logEntry.context = sanitized;
  }

  const line = JSON.stringify(logEntry);
  switch (level) {
    case 'ERROR':
      console.error(line);
      break;
    case 'WARN':
      console.warn(line);
      break;
    case 'DEBUG':
      console.debug(line);
      break;
    default:
      console.log(line);
      break;
  }
}

export interface AppLogger {
  debug(message: string, context?: LogContext): void;
  info(message: string, context?: LogContext): void;
  warn(message: string, context?: LogContext): void;
  error(message: string, context?: LogContext): void;
  child(context: LogContext): AppLogger;
}

export function createLogger(defaultContext: LogContext = {}): AppLogger {
  const baseContext = sanitizeContext(defaultContext) ?? {};

  const logWithLevel = (level: LogLevel, message: string, context?: LogContext) => {
    output(level, message, { ...baseContext, ...sanitizeContext(context) });
  };

  return {
    debug: (message, context) => logWithLevel('DEBUG', message, context),
    info: (message, context) => logWithLevel('INFO', message, context),
    warn: (message, context) => logWithLevel('WARN', message, context),
    error: (message, context) => logWithLevel('ERROR', message, context),
    child: (context: LogContext) => createLogger({ ...baseContext, ...context }),
  };
}

export function serializeError(error: unknown): LogContext {
  if (error instanceof Error) {
    return formatError(error);
  }
  if (typeof error === 'object' && error !== null) {
    const maybeError = error as { message?: string };
    return {
      name: 'UnknownError',
      message: maybeError.message ?? JSON.stringify(error),
    };
  }
  return {
    name: 'UnknownError',
    message: String(error),
  };
}

