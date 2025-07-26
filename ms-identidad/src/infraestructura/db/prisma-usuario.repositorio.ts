import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma.service';
import * as bcrypt from 'bcrypt';
import { User, Athlete, Gym } from '@prisma/client';

import {
  IUsuarioRepositorio,
} from '../../dominio/repositorios/usuario.repositorio';
import { PerfilAtletaActualizable } from '../../dominio/tipos/tipos-dominio';
import {
  Usuario,
  RolUsuario,
  PerfilAtletaDominio,
  GimnasioDominio,
} from '../../dominio/entidades/usuario.entity';

// Tipo local para la respuesta enriquecida de Prisma
type UsuarioConPerfilCompleto = User & {
  athleteProfile: Athlete | null;
  gyms: ({ gym: Gym })[];
};

@Injectable()
export class PrismaUsuarioRepositorio implements IUsuarioRepositorio {
  constructor(private readonly prisma: PrismaService) {}

  public async encontrarPorEmail(email: string): Promise<Usuario | null> {
    const usuarioDb = await this.prisma.user.findUnique({
      where: { email },
      include: {
        athleteProfile: true,
        gyms: { include: { gym: true } },
      },
    });
    return usuarioDb ? this.mapearADominio(usuarioDb) : null;
  }

  public async encontrarPorId(id: string): Promise<Usuario | null> {
    const usuarioDb = await this.prisma.user.findUnique({
      where: { id },
      include: {
        athleteProfile: true,
        gyms: { include: { gym: true } },
      },
    });
    return usuarioDb ? this.mapearADominio(usuarioDb) : null;
  }

  public async guardar(usuario: Usuario): Promise<Usuario> {
    const usuarioGuardadoDb = await this.prisma.user.create({
      data: {
        id: usuario.id,
        email: usuario.email,
        password_hash: usuario.obtenerPasswordHash(),
        name: usuario.nombre,
        role: usuario.rol,
        refresh_token_hash: usuario.refreshTokenHash,
        fcm_token: usuario.fcmToken,
      },
    });
    const usuarioCompleto = await this.encontrarPorId(usuarioGuardadoDb.id);
    return usuarioCompleto!;
  }

  public async actualizarPassword(
    usuarioId: string,
    nuevaPasswordPlano: string,
  ): Promise<void> {
    const saltRounds = 10;
    const nuevoPasswordHash = await bcrypt.hash(nuevaPasswordPlano, saltRounds);
    await this.prisma.user.update({
      where: { id: usuarioId },
      data: { password_hash: nuevoPasswordHash },
    });
  }

  public async actualizarPerfilAtleta(
    atletaId: string,
    datos: PerfilAtletaActualizable,
  ): Promise<void> {
    await this.prisma.athlete.upsert({
      where: { userId: atletaId },
      update: {
        level: datos.nivel,
        height_cm: datos.alturaCm,
        weight_kg: datos.pesoKg,
        stance: datos.guardia,
        allergies: datos.alergias,
        emergency_contact_name: datos.contactoEmergenciaNombre,
        emergency_contact_phone: datos.contactoEmergenciaTelefono,
      },
      create: {
        userId: atletaId,
        level: datos.nivel,
        height_cm: datos.alturaCm,
        weight_kg: datos.pesoKg,
        stance: datos.guardia,
        allergies: datos.alergias,
        emergency_contact_name: datos.contactoEmergenciaNombre,
        emergency_contact_phone: datos.contactoEmergenciaTelefono,
      },
    });
  }

  public async actualizarRefreshToken(
    usuarioId: string,
    refreshToken: string | null,
  ): Promise<void> {
    const refreshTokenHash = refreshToken
      ? await bcrypt.hash(refreshToken, 10)
      : null;
    await this.prisma.user.update({
      where: { id: usuarioId },
      data: { refresh_token_hash: refreshTokenHash },
    });
  }

  /**
   * Implementación del nuevo método para asociar un usuario a un gimnasio.
   */
  public async asociarAGimnasio(usuarioId: string, gymId: string): Promise<void> {
    await this.prisma.userGymRelation.create({
      data: {
        userId: usuarioId,
        gymId: gymId,
      },
    });
  }

  private mapearADominio(usuarioDb: UsuarioConPerfilCompleto): Usuario {
    let perfilAtletaDominio: PerfilAtletaDominio | null = null;
    if (usuarioDb.athleteProfile) {
      perfilAtletaDominio = {
        nivel: usuarioDb.athleteProfile.level,
        alturaCm: usuarioDb.athleteProfile.height_cm,
        pesoKg: usuarioDb.athleteProfile.weight_kg,
        guardia: usuarioDb.athleteProfile.stance,
        alergias: usuarioDb.athleteProfile.allergies,
        contactoEmergenciaNombre:
          usuarioDb.athleteProfile.emergency_contact_name,
        contactoEmergenciaTelefono:
          usuarioDb.athleteProfile.emergency_contact_phone,
      };
    }

    let gimnasioDominio: GimnasioDominio | null = null;
    if (usuarioDb.gyms && usuarioDb.gyms.length > 0) {
      gimnasioDominio = {
        id: usuarioDb.gyms[0].gym.id,
        nombre: usuarioDb.gyms[0].gym.name,
      };
    }

    return Usuario.desdePersistencia({
      id: usuarioDb.id,
      email: usuarioDb.email,
      passwordHash: usuarioDb.password_hash ?? '',
      refreshTokenHash: usuarioDb.refresh_token_hash,
      fcmToken: usuarioDb.fcm_token,
      nombre: usuarioDb.name,
      rol: usuarioDb.role as RolUsuario,
      createdAt: usuarioDb.createdAt,
      perfilAtleta: perfilAtletaDominio,
      gimnasio: gimnasioDominio,
    });
  }
}
