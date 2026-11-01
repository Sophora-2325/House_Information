import { defineConfig } from 'vitest/config';
import tsconfigPaths from 'vite-tsconfig-paths';

export default defineConfig({
  plugins: [tsconfigPaths()],
  test: {
    globals: true,
    root: './',
    include: ['**/*.e2e-spec.ts'],
    fileParallelism: false,
    env: {
      DATABASE_URL:
        process.env.TEST_DATABASE_URL ??
        'postgresql://fangshi:fangshi_dev@127.0.0.1:5432/fangshi_test',
      JWT_SECRET: 'test-secret',
      SMS_DEV_CODE: '123456',
    },
  },
});
