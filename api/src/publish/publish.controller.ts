import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { PublishService } from './publish.service';
import { PublishDto } from './dto/publish.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('admin/publish')
export class PublishController {
  constructor(private readonly publishService: PublishService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  publish(@Body() publishDto: PublishDto) {
    return this.publishService.publish(publishDto);
  }
}
