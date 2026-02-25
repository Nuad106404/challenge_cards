import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import { ModesService } from './modes.service';
import { CreateGameModeDto } from './dto/create-game-mode.dto';
import { UpdateGameModeDto } from './dto/update-game-mode.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller()
export class ModesController {
  constructor(private readonly modesService: ModesService) {}

  // ─── Public Endpoints ───────────────────────────────────────────────────────

  @Get('public/modes')
  findPublic() {
    return this.modesService.findAll(true);
  }

  // ─── Admin Endpoints ─────────────────────────────────────────────────────────

  @Post('admin/modes')
  @UseGuards(JwtAuthGuard)
  create(@Body() dto: CreateGameModeDto) {
    return this.modesService.create(dto);
  }

  @Get('admin/modes')
  @UseGuards(JwtAuthGuard)
  findAll() {
    return this.modesService.findAll(false);
  }

  @Get('admin/modes/:id')
  @UseGuards(JwtAuthGuard)
  findOne(@Param('id') id: string) {
    return this.modesService.findOne(id);
  }

  @Put('admin/modes/:id')
  @UseGuards(JwtAuthGuard)
  update(@Param('id') id: string, @Body() dto: UpdateGameModeDto) {
    return this.modesService.update(id, dto);
  }

  @Delete('admin/modes/:id')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    return this.modesService.remove(id);
  }
}
