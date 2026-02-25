import { IsBoolean, IsNumber, IsOptional, IsString } from 'class-validator';

export class UpdateLocalAdDto {
  @IsString()
  @IsOptional()
  label?: string;

  @IsString()
  @IsOptional()
  imageUrl?: string;

  @IsString()
  @IsOptional()
  linkUrl?: string;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsNumber()
  @IsOptional()
  order?: number;
}
