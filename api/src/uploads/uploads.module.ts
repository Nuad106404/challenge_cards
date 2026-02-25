import { Module } from '@nestjs/common';
import { MulterModule } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { existsSync, mkdirSync } from 'fs';
import { UploadsController } from './uploads.controller';
import { UploadsService } from './uploads.service';

// Determine upload directory based on environment
const uploadDir = process.env.NODE_ENV === 'production' 
  ? '/var/www/challenge-cards/uploads/cards'
  : join(process.cwd(), 'uploads', 'cards');

// Ensure directory exists
if (!existsSync(uploadDir)) {
  mkdirSync(uploadDir, { recursive: true });
}

@Module({
  imports: [
    MulterModule.register({
      storage: diskStorage({
        destination: uploadDir,
        filename: (req, file, cb) => {
          const timestamp = Date.now();
          const randomStr = Math.random().toString(36).substring(2, 8);
          const ext = extname(file.originalname);
          cb(null, `${timestamp}_${randomStr}${ext}`);
        },
      }),
      limits: {
        fileSize: 5 * 1024 * 1024, // 5MB
      },
      fileFilter: (req, file, cb) => {
        const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
        if (allowedMimes.includes(file.mimetype)) {
          cb(null, true);
        } else {
          cb(new Error('Invalid file type. Only JPG, PNG, and WebP are allowed.'), false);
        }
      },
    }),
  ],
  controllers: [UploadsController],
  providers: [UploadsService],
  exports: [UploadsService],
})
export class UploadsModule {}
