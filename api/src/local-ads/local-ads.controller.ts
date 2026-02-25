import {
  Controller, Get, Post, Put, Patch, Delete,
  Body, Param, UseGuards, UploadedFile, UseInterceptors, BadRequestException,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname, join } from 'path';
import { LocalAdsService } from './local-ads.service';
import { CreateLocalAdDto } from './dto/create-local-ad.dto';
import { UpdateLocalAdDto } from './dto/update-local-ad.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { IsArray, IsString } from 'class-validator';

class ReorderDto {
  @IsArray()
  @IsString({ each: true })
  ids: string[];
}

@Controller()
export class LocalAdsController {
  constructor(private readonly localAdsService: LocalAdsService) {}

  // ─── Public ──────────────────────────────────────────────────────────────────

  @Get('public/local-ads')
  getActiveAds() {
    return this.localAdsService.findActive();
  }

  // ─── Admin ───────────────────────────────────────────────────────────────────

  @Get('admin/local-ads')
  @UseGuards(JwtAuthGuard)
  findAll() {
    return this.localAdsService.findAll();
  }

  @Post('admin/local-ads')
  @UseGuards(JwtAuthGuard)
  create(@Body() dto: CreateLocalAdDto) {
    return this.localAdsService.create(dto);
  }

  @Put('admin/local-ads/:id')
  @UseGuards(JwtAuthGuard)
  update(@Param('id') id: string, @Body() dto: UpdateLocalAdDto) {
    return this.localAdsService.update(id, dto);
  }

  @Patch('admin/local-ads/:id/toggle')
  @UseGuards(JwtAuthGuard)
  toggle(@Param('id') id: string) {
    return this.localAdsService.toggle(id);
  }

  @Delete('admin/local-ads/:id')
  @UseGuards(JwtAuthGuard)
  remove(@Param('id') id: string) {
    return this.localAdsService.remove(id);
  }

  @Post('admin/local-ads/reorder')
  @UseGuards(JwtAuthGuard)
  reorder(@Body() dto: ReorderDto) {
    return this.localAdsService.reorder(dto.ids);
  }

  @Post('admin/local-ads/upload-image')
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: join(process.cwd(), 'uploads', 'ads'),
        filename: (_req, file, cb) => {
          const unique = Date.now() + '-' + Math.round(Math.random() * 1e9);
          cb(null, `ad-${unique}${extname(file.originalname)}`);
        },
      }),
      fileFilter: (_req, file, cb) => {
        if (!file.mimetype.match(/^image\//)) {
          return cb(new BadRequestException('Only image files are allowed'), false);
        }
        cb(null, true);
      },
      limits: { fileSize: 5 * 1024 * 1024 },
    }),
  )
  uploadImage(@UploadedFile() file: Express.Multer.File) {
    if (!file) throw new BadRequestException('No file uploaded');
    return { url: `/uploads/ads/${file.filename}` };
  }
}
