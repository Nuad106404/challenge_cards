import { IsMongoId, IsOptional } from 'class-validator';

export class PublishDto {
  @IsMongoId()
  @IsOptional()
  packId?: string;
}
