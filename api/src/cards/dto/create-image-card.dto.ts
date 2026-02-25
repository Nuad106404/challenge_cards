import { IsString, IsEnum, IsArray, IsOptional, IsObject, ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

class ImageMetaDto {
  @IsOptional()
  width?: number;

  @IsOptional()
  height?: number;

  @IsOptional()
  size?: number;

  @IsOptional()
  @IsString()
  mime?: string;
}

export class CreateImageCardDto {
  @IsString()
  packId: string;

  @IsEnum(['question', 'dare', 'vote', 'punishment', 'bonus', 'minigame'])
  type: string;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  tags?: string[];

  @IsEnum(['easy', 'medium', 'hard'])
  @IsOptional()
  difficulty?: string;

  @IsEnum(['all', '18+'])
  @IsOptional()
  ageRating?: string;

  @IsEnum(['draft', 'review', 'published'])
  @IsOptional()
  status?: string;

  @IsString()
  imageUrl: string;

  @IsObject()
  @ValidateNested()
  @Type(() => ImageMetaDto)
  @IsOptional()
  imageMeta?: ImageMetaDto;
}
