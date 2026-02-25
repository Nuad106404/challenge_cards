import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { JwtService } from '@nestjs/jwt';
import { Model } from 'mongoose';
import * as bcrypt from 'bcryptjs';
import { AdminUser, AdminUserDocument } from './schemas/admin-user.schema';
import { LoginDto } from './dto/login.dto';
import { CreateAdminDto } from './dto/create-admin.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectModel(AdminUser.name) private adminUserModel: Model<AdminUserDocument>,
    private jwtService: JwtService,
  ) {}

  async login(loginDto: LoginDto): Promise<{ accessToken: string; user: Partial<AdminUser> }> {
    const user = await this.adminUserModel.findOne({ userId: loginDto.userId }).exec();
    if (!user || !user.isActive) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const isMatch = await bcrypt.compare(loginDto.password, user.passwordHash);
    if (!isMatch) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const payload = { sub: user._id.toString(), userId: user.userId, role: user.role };
    const accessToken = this.jwtService.sign(payload);

    return {
      accessToken,
      user: { userId: user.userId, name: user.name, role: user.role, isActive: user.isActive },
    };
  }

  async createAdmin(createAdminDto: CreateAdminDto): Promise<AdminUser> {
    const existing = await this.adminUserModel.findOne({ userId: createAdminDto.userId }).exec();
    if (existing) {
      throw new ConflictException('User ID already in use');
    }

    const passwordHash = await bcrypt.hash(createAdminDto.password, 12);
    const admin = new this.adminUserModel({
      userId: createAdminDto.userId,
      name: createAdminDto.name,
      passwordHash,
      role: createAdminDto.role,
    });

    return admin.save();
  }

  async seedAdminFromEnv(): Promise<void> {
    const userId = process.env.ADMIN_ID;
    const password = process.env.ADMIN_PASSWORD;
    const name = process.env.ADMIN_NAME ?? 'Admin';

    if (!userId || !password) return;

    const existing = await this.adminUserModel.findOne({ userId }).exec();
    if (existing) return;

    const passwordHash = await bcrypt.hash(password, 12);
    await this.adminUserModel.create({ userId, name, passwordHash, role: 'admin' });
    console.log(`[Auth] Seeded admin user: ${userId}`);
  }

  async findAll(): Promise<AdminUser[]> {
    return this.adminUserModel.find({}, { passwordHash: 0 }).exec();
  }
}
