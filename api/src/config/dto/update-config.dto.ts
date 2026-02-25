import { IsArray, IsBoolean, IsNumber, IsOptional, IsString, ValidateNested, Min, Max } from 'class-validator';
import { Type } from 'class-transformer';

class SupportedLanguageDto {
  @IsString()
  code: string;

  @IsString()
  label: string;
}

export class UpdateConfigDto {
  @IsBoolean()
  @IsOptional()
  adsEnabled?: boolean;

  @IsString()
  @IsOptional()
  admobAppId?: string;

  @IsString()
  @IsOptional()
  admobBannerId?: string;

  @IsString()
  @IsOptional()
  admobInterstitialId?: string;

  @IsNumber()
  @Min(1)
  @Max(60)
  @IsOptional()
  adRotationDuration?: number;

  @IsString()
  @IsOptional()
  minAppVersion?: string;

  @IsString()
  @IsOptional()
  apiBaseUrl?: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => SupportedLanguageDto)
  @IsOptional()
  supportedLanguages?: SupportedLanguageDto[];
}
