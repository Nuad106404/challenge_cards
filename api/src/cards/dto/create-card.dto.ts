import {
  IsArray,
  IsBoolean,
  IsEnum,
  IsInt,
  IsMongoId,
  IsObject,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class CreateCardDto {
  @IsMongoId()
  packId: string;

  @IsEnum(['question', 'dare', 'vote', 'punishment', 'bonus', 'minigame'])
  type: string;

  @IsObject()
  text: Record<string, string>;

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

  @IsInt()
  @Min(0)
  @Max(6)
  @IsOptional()
  diceCount?: number;

  @IsBoolean()
  @IsOptional()
  isActive?: boolean;

  @IsEnum(['draft', 'review', 'published'])
  @IsOptional()
  status?: string;
}
