import { Controller, Get, Put, Body, UseGuards } from '@nestjs/common';
import { AppConfigService } from './config.service';
import { UpdateConfigDto } from './dto/update-config.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller()
export class AppConfigController {
  constructor(private readonly appConfigService: AppConfigService) {}

  // ─── Public Endpoint ─────────────────────────────────────────────────────────

  @Get('public/config')
  getPublicConfig() {
    return this.appConfigService.getConfig();
  }

  // ─── Admin Endpoint ──────────────────────────────────────────────────────────

  @Get('admin/config')
  @UseGuards(JwtAuthGuard)
  getConfig() {
    return this.appConfigService.getConfig();
  }

  @Put('admin/config')
  @UseGuards(JwtAuthGuard)
  updateConfig(@Body() updateConfigDto: UpdateConfigDto) {
    return this.appConfigService.updateConfig(updateConfigDto);
  }
}
