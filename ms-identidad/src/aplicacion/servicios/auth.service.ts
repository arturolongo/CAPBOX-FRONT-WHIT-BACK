import {
  Inject,
  Injectable,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';
import { IUsuarioRepositorio } from '../../dominio/repositorios/usuario.repositorio';
import { Usuario } from '../../dominio/entidades/usuario.entity';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AuthService {
  constructor(
    @Inject('IUsuarioRepositorio')
    private readonly usuarioRepositorio: IUsuarioRepositorio,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  public validarCliente(clientId: string, clientSecret: string): boolean {
    const validClientId = this.configService.get<string>('OAUTH_CLIENT_ID');
    const validClientSecret = this.configService.get<string>(
      'OAUTH_CLIENT_SECRET',
    );
    return clientId === validClientId && clientSecret === validClientSecret;
  }

  public async validarCredencialesUsuario(
    email: string,
    pass: string,
  ): Promise<Usuario | null> {
    const usuario = await this.usuarioRepositorio.encontrarPorEmail(email);
    if (usuario && (await bcrypt.compare(pass, usuario.obtenerPasswordHash()))) {
      return usuario;
    }
    return null;
  }

  public async generarTokens(
    usuario: Usuario,
  ): Promise<{ access_token: string; refresh_token: string }> {
    const accessTokenPayload = {
      sub: usuario.id,
      email: usuario.email,
      rol: usuario.rol,
    };
    const refreshTokenPayload = {
      sub: usuario.id,
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(accessTokenPayload, {
        secret: this.configService.get<string>('JWT_SECRET'),
        expiresIn: this.configService.get<string>('JWT_ACCESS_TOKEN_EXPIRATION'),
      }),
      this.jwtService.signAsync(refreshTokenPayload, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
        expiresIn: this.configService.get<string>('JWT_REFRESH_TOKEN_EXPIRATION'),
      }),
    ]);

    await this.usuarioRepositorio.actualizarRefreshToken(
      usuario.id,
      refreshToken,
    );

    return {
      access_token: accessToken,
      refresh_token: refreshToken,
    };
  }

  public async validarUsuarioPorRefreshToken(
    userId: string,
    refreshToken: string,
  ): Promise<Usuario | null> {
    const usuario = await this.usuarioRepositorio.encontrarPorId(userId);
    if (!usuario || !usuario.obtenerRefreshTokenHash()) {
      return null;
    }
    const refreshTokenValido = await bcrypt.compare(
      refreshToken,
      usuario.obtenerRefreshTokenHash(),
    );
    return refreshTokenValido ? usuario : null;
  }

  /**
   * Cierra la sesión de un usuario invalidando su refresh token.
   * @param usuarioId El ID del usuario que está cerrando sesión.
   */
  public async cerrarSesion(usuarioId: string): Promise<{ mensaje: string }> {
    // La forma de invalidar el refresh token es simplemente eliminarlo de la base de datos.
    await this.usuarioRepositorio.actualizarRefreshToken(usuarioId, null);
    return { mensaje: 'Sesión cerrada con éxito.' };
  }

  public async solicitarReseteoPassword(
    email: string,
  ): Promise<{ mensaje: string }> {
    const usuario = await this.usuarioRepositorio.encontrarPorEmail(email);
    if (!usuario) {
      return {
        mensaje:
          'Si existe una cuenta con este correo, se ha enviado un enlace para restablecer la contraseña.',
      };
    }
    const tokenPayload = { sub: usuario.id, type: 'password-reset' };
    const resetToken = this.jwtService.sign(tokenPayload, { expiresIn: '15m' });
    console.log(
      `[SIMULACIÓN DE EMAIL] Enviando a: ${usuario.email} con el siguiente token de reseteo: ${resetToken}`,
    );
    return {
      mensaje:
        'Si existe una cuenta con este correo, se ha enviado un enlace para restablecer la contraseña.',
    };
  }

  public async resetearPassword(
    token: string,
    nuevaPassword: string,
  ): Promise<{ mensaje: string }> {
    try {
      const payload: { sub: string; type: string } =
        this.jwtService.verify(token);
      if (payload.type !== 'password-reset') {
        throw new UnauthorizedException('Token inválido para esta operación.');
      }
      const usuario = await this.usuarioRepositorio.encontrarPorId(payload.sub);
      if (!usuario) {
        throw new NotFoundException('Usuario asociado al token no encontrado.');
      }
      await this.usuarioRepositorio.actualizarPassword(
        usuario.id,
        nuevaPassword,
      );
      return { mensaje: 'Contraseña actualizada con éxito.' };
    } catch (error) {
      throw new UnauthorizedException(
        'El token de restablecimiento es inválido o ha expirado.',
      );
    }
  }
}
