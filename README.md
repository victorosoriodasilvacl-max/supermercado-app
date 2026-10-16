# Supermercado App — Demo White-Label

Demo de e-commerce para supermercados, 100% personalizable por el cliente
desde la propia app (sin tocar código): logo, nombre, colores, fotos,
productos, redes sociales y asistente de IA.

- **Demo en vivo:** https://victorosoriodasilvacl-max.github.io/supermercado-app/
- **Stack actual:** Flutter (web + Android), sin backend todavía — todo
  corre en memoria durante la sesión del navegador.
- **Stack objetivo (próxima fase):** Flutter + Supabase (base de datos,
  auth, storage de imágenes) + Gemini Flash para el asistente de IA real.

## Cómo correrlo localmente

```bash
flutter pub get
flutter run -d chrome          # o `flutter run` para un dispositivo/emulador
```

## Cómo se publica la demo (GitHub Pages)

La rama `main` tiene el código fuente. La rama `gh-pages` tiene el **build
compilado** (`flutter build web`) que GitHub Pages sirve directamente — no
se edita a mano, se regenera así:

```bash
flutter build web --release --base-href "/supermercado-app/"

# Copiar build/web a la raíz de la rama gh-pages, commitear y pushear.
# (Ver el historial de commits en gh-pages para el detalle exacto de los
# comandos usados.)
```

Repo público porque GitHub Pages gratis no sirve sitios desde repos
privados; el código no tiene API keys ni datos sensibles.

## Qué incluye la demo hoy

### Cara al comprador
- **Pantalla de bienvenida/login**: portada a pantalla completa; el login
  (logo, nombre, usuario/clave) aparece al mover el mouse o tocar la
  pantalla. Acepta cualquier usuario/clave — es mock, ver nota de
  seguridad más abajo.
- **Catálogo**: búsqueda, filtro por categoría, tarjetas de producto con
  oferta (tachado + etiqueta de color de marca).
- **Carrito** y **checkout completo**: delivery o retiro en tienda,
  dirección/horario, medio de pago, confirmación.
- **Seguimiento de pedido**: avanza solo (Preparando → En camino/Listo
  para retiro → Entregado), con código de retiro si aplica.
- **Pie de página**: Instagram, Facebook, TikTok y WhatsApp (con íconos de
  marca reales), solo se muestran los que el cliente configura.
- **Asistente de IA** (botón flotante, ícono y nombre personalizables):
  responde stock, precios, ofertas y arma un presupuesto con el carrito
  actual. Hoy es **lógica local** (reglas en
  `lib/services/ai_assistant.dart`), no llama a ningún servicio externo.

### Panel de control del cliente (sin login separado todavía)
- **Personalizar marca** (ícono 🎨): nombre, eslogan, logo (preset o foto
  propia), imagen de portada (preset "temas de supermercado" o foto
  propia), fondo de toda la página, fondo de la pantalla de bienvenida,
  colores primario/secundario, redes sociales y WhatsApp, nombre e ícono
  del asistente de IA.
- **Fotos y productos** (ícono 📷): un panel por categoría; cada uno
  permite agregar productos ilimitados con foto (sube desde el PC/celular
  vía selector de archivos), nombre, descripción, precio, unidad y si
  está en oferta (con precio anterior). Editar o eliminar productos
  existentes tocándolos.

## Decisiones técnicas a tener en cuenta

- **Todo vive en memoria** (`lib/state/app_state.dart`, `ChangeNotifier` +
  `provider`): recargar la página borra los cambios. Es intencional para
  esta fase — el próximo paso es persistir en Supabase.
- **El asistente de IA es local, no Gemini.** Conectar un modelo real
  (ej. Gemini Flash, que es barato y rápido para solo texto) requiere un
  backend que guarde la API key — nunca debe ir en el cliente/navegador,
  porque cualquiera podría leerla del código fuente servido y usarla a
  costa del cliente.
- **El login es decorativo.** No hay autenticación real; cualquier
  usuario/clave entra. Antes de que el panel de control (precios,
  productos) quede expuesto en producción, hay que meter auth real con
  token — si no, cualquiera que encuentre la URL puede cambiar precios.
- **Imágenes solo en memoria del navegador**, no se suben a ningún lado
  todavía (no hay backend). Eso también es tarea de la fase Supabase.

## Pendiente para la siguiente fase (producción real)

1. Backend con Supabase: base de datos para tenants/productos/pedidos,
   Storage para las imágenes, Auth real para el panel de control.
2. Asistente de IA con Gemini Flash vía función de backend (Edge
   Function de Supabase, por ejemplo), nunca con la key en el cliente.
3. Multi-tenant real: hoy la demo es de un solo "cliente" a la vez en el
   navegador; en producción cada supermercado tiene su propia cuenta y
   datos aislados.
4. Pasarela de pago real (hoy el checkout solo simula el pago).
5. Notificaciones de pedido reales (push/SMS/WhatsApp) en vez de la
   simulación con `Timer`.
6. Build de Android (APK/AAB) para publicar en Play Store o compartir
   directo — no se generó en esta fase por falta de Android SDK en el
   entorno de este sandbox.
