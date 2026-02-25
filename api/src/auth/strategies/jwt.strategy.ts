import { Injectable, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectModel } from '@nestjs/mongoose';
import { PassportStrategy } from '@nestjs/passport';
import { Model } from 'mongoose';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { AdminUser, AdminUserDocument } from '../schemas/admin-user.schema';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    configService: ConfigService,
    @InjectModel(AdminUser.name) private adminUserModel: Model<AdminUserDocument>,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET'),
    });
  }

  async validate(payload: { sub: string; userId: string; role: string }) {
    const user = await this.adminUserModel.findById(payload.sub).exec();
    if (!user || !user.isActive) {
      throw new UnauthorizedException('User not found or inactive');
    }
    return { _id: payload.sub, userId: payload.userId, role: payload.role };
  }
}
