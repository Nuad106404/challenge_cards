import { IsBoolean, IsNumber, IsOptional, IsString } from 'class-validator';

export class CreateLocalAdDto {
  @IsString()
  label: string;

  @IsString()
  imageUrl: string;

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
