import { IsEnum, IsString, MinLength } from 'class-validator';

export class CreateAdminDto {
  @IsString()
  userId: string;

  @IsString()
  name: string;

  @IsString()
  @MinLength(8)
  password: string;

  @IsEnum(['admin', 'editor'])
  role: string;
}
