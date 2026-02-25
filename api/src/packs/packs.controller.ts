import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { PacksService } from './packs.service';
import { CreatePackDto } from './dto/create-pack.dto';
import { UpdatePackDto } from './dto/update-pack.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller()
export class PacksController {
  constructor(private readonly packsService: PacksService) {}

  // ─── Public Endpoints ───────────────────────────────────────────────────────

  @Get('public/packs')
  findPublic(
    @Query('mode') mode?: string,
    @Query('ageRating') ageRating?: string,
  ) {
    return this.packsService.findAll({ mode, ageRating, isActive: true });
  }

  @Get('public/packs/:id')
  findOnePublic(@Param('id') id: string) {
    return this.packsService.findOne(id);
  }

  // ─── Admin Endpoints ─────────────────────────────────────────────────────────

  @Post('admin/packs')
  @UseGuards(JwtAuthGuard)
  create(@Body() createPackDto: CreatePackDto) {
    return this.packsService.create(createPackDto);
  }

  @Get('admin/packs')
  @UseGuards(JwtAuthGuard)
  findAll(
    @Query('mode') mode?: string,
    @Query('ageRating') ageRating?: string,
    @Query('isActive') isActive?: string,
  ) {
    const isActiveFilter = isActive !== undefined ? isActive === 'true' : undefined;
    return this.packsService.findAll({ mode, ageRating, isActive: isActiveFilter });
  }

  @Get('admin/packs/:id')
  @UseGuards(JwtAuthGuard)
  findOne(@Param('id') id: string) {
    return this.packsService.findOne(id);
  }

  @Put('admin/packs/:id')
  @UseGuards(JwtAuthGuard)
  update(@Param('id') id: string, @Body() updatePackDto: UpdatePackDto) {
    return this.packsService.update(id, updatePackDto);
  }

  @Delete('admin/packs/:id')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    return this.packsService.remove(id);
  }
}
