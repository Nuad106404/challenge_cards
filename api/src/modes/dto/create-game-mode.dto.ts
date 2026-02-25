import {
  IsBoolean,
  IsNumber,
  IsObject,
  IsOptional,
  IsString,
  MinLength,
} from 'class-validator';

export class CreateGameModeDto {
  @IsString()
  @MinLength(2)
  slug: string;

  @IsObject()
  name: Record<string, string>;

  @IsObject()
  description: Record<string, string>;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsNumber()
  @IsOptional()
  sortOrder?: number;
}
