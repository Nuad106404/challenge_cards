import {
  IsBoolean,
  IsEnum,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';

export class CreatePackDto {
  @IsString()
  @MinLength(2)
  slug: string;

  @IsObject()
  title: Record<string, string>;

  @IsObject()
  description: Record<string, string>;

  @IsString()
  @MinLength(2)
  mode: string;

  @IsEnum(['all', '18+'])
  @IsOptional()
  ageRating?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsString()
  @IsOptional()
  coverImageUrl?: string;

  @IsNumber()
  @IsOptional()
  sortOrder?: number;
}
