import { Injectable } from '@nestjs/common';
import * as sharp from 'sharp';
import { ConfigService } from '@nestjs/config';

export interface UploadedFileInfo {
  url: string;
  path: string;
  mime: string;
  size: number;
  width: number;
  height: number;
}

@Injectable()
export class UploadsService {
  constructor(private configService: ConfigService) {}

  async processCardImage(file: Express.Multer.File): Promise<UploadedFileInfo> {
    const apiBaseUrl = this.configService.get<string>('API_BASE_URL') || 'http://localhost:3001';
    const baseUrl = apiBaseUrl.endsWith('/api') ? apiBaseUrl.substring(0, apiBaseUrl.length - 4) : apiBaseUrl;
    
    // Get image dimensions using sharp
    const metadata = await sharp(file.path).metadata();
    
    return {
      url: `${baseUrl}/uploads/cards/${file.filename}`,
      path: file.path,
      mime: file.mimetype,
      size: file.size,
      width: metadata.width || 0,
      height: metadata.height || 0,
    };
  }
}
