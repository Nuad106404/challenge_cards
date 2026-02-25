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
import { CardsService } from './cards.service';
import { CreateCardDto } from './dto/create-card.dto';
import { CreateImageCardDto } from './dto/create-image-card.dto';
import { UpdateCardDto } from './dto/update-card.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller()
export class CardsController {
  constructor(private readonly cardsService: CardsService) {}

  // ─── Public Endpoints ───────────────────────────────────────────────────────

  @Get('public/cards')
  findPublic(
    @Query('packId') packId?: string,
    @Query('ageRating') ageRating?: string,
  ) {
    if (packId) {
      return this.cardsService.findByPack(packId, ageRating);
    }
    return this.cardsService.findAll({ isActive: true, status: 'published', ageRating });
  }

  @Get('public/cards/:id')
  findOnePublic(@Param('id') id: string) {
    return this.cardsService.findOne(id);
  }

  // ─── Admin Endpoints ─────────────────────────────────────────────────────────

  @Post('admin/cards')
  @UseGuards(JwtAuthGuard)
  create(@Body() createCardDto: CreateCardDto) {
    return this.cardsService.create(createCardDto);
  }

  @Post('admin/cards/image')
  @UseGuards(JwtAuthGuard)
  createImageCard(@Body() createImageCardDto: CreateImageCardDto) {
    return this.cardsService.createImageCard(createImageCardDto);
  }

  @Get('admin/cards')
  @UseGuards(JwtAuthGuard)
  findAll(
    @Query('packId') packId?: string,
    @Query('type') type?: string,
    @Query('ageRating') ageRating?: string,
    @Query('status') status?: string,
    @Query('isActive') isActive?: string,
  ) {
    const isActiveFilter = isActive !== undefined ? isActive === 'true' : undefined;
    return this.cardsService.findAll({ packId, type, ageRating, status, isActive: isActiveFilter });
  }

  @Get('admin/cards/:id')
  @UseGuards(JwtAuthGuard)
  findOne(@Param('id') id: string) {
    return this.cardsService.findOne(id);
  }

  @Put('admin/cards/:id')
  @UseGuards(JwtAuthGuard)
  update(@Param('id') id: string, @Body() updateCardDto: UpdateCardDto) {
    return this.cardsService.update(id, updateCardDto);
  }

  @Delete('admin/cards/:id')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(@Param('id') id: string) {
    return this.cardsService.remove(id);
  }
}
