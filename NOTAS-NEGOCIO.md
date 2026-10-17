# Notas de negocio — Supermercado App

Apuntes de la conversación sobre cómo convertir la demo en un producto que
se pueda vender/arrendar. No es documentación técnica (para eso está el
`README.md`) — esto es estrategia y precios, a revisar y ajustar con datos
reales a medida que avancemos.

## Modelo de cobro

- **SaaS por tienda (tenant), no por usuario ni por comprador final.**
  Los clientes que compran en el supermercado nunca pagan ni cuentan para
  la tarifa.
- Si un mismo dueño quiere varias tiendas con catálogos independientes,
  son varias suscripciones (o un plan "multi-sucursal" que las agrupa).
- Lo que sí puede escalar el precio dentro de un mismo plan:
  - Cantidad de productos en el catálogo.
  - Cantidad de pedidos al mes.
  - Si usa o no el asistente de IA (tiene costo real de API por consulta).
  - Multi-sucursal sí/no.
  - Cantidad de usuarios administradores con acceso al panel.

## Estructura de precios (estimación, no cifra de mercado confirmada)

No se encontraron precios públicos exactos de competidores chilenos
(Tiendanube/Jumpseller no publican montos en CLP de forma clara). Esta
tabla es una referencia de partida, a ajustar con el primer cliente real:

| Plan | Incluye | CLP/mes (estimado) |
|---|---|---|
| Básico | Catálogo, carrito, checkout, 1 admin | $25.000 – $45.000 |
| Estándar | + IA, personalización de marca completa, redes/WhatsApp | $50.000 – $90.000 |
| Pro / Multi-sucursal | + multi-tenant, reportes, soporte prioritario | $100.000 – $180.000 |

- **Setup inicial** (montar la tienda con su marca y catálogo): pago único
  aparte de la mensualidad, estimado $150.000 – $400.000 según cuánto
  trabajo de carga de datos implique.
- Referencia externa usada: Shopify (EE.UU./LatAm) cobra entre US$25 y
  US$399/mes según plan, más comisión por transacción.

**Recomendación:** no anclarse a estos números. Lanzar con un plan piloto
más bajo para el primer cliente real (ej. $40.000–$60.000/mes), aprender
costos reales de mantener la plataforma (Supabase, soporte) y desde ahí
fijar la tabla definitiva.

## Por qué el negocio no es "un cliente a 40 lucas"

La gracia del modelo SaaS está en la repetición, no en un cliente:

- 20 tiendas a ~$60.000/mes promedio = **~$1.200.000/mes recurrentes**,
  sin vender nada físico.
- El setup inicial se cobra aparte, por cada cliente nuevo.
- El costo real de mantener cada tienda corriendo (Supabase + hosting) es
  bajo comparado con lo cobrado — alto margen una vez armada la base.
- Cada cliente nuevo es casi puro margen porque el producto ya existe
  (white-label), no es un proyecto a medida desde cero.
- Si el volumen de pymes chicas no conviene, la alternativa es apuntar a
  cadenas con varias sucursales (planes multi-tienda, cifras bastante
  más altas por cliente).

## Cómo conseguir los primeros clientes

Orden sugerido, de más a menos prioritario al principio:

1. **Landing page** con la demo embebida, precios y botón de contacto
   (WhatsApp o formulario) — la vitrina, no el canal de venta.
2. **Venta directa** a almacenes/minimarkets cercanos, mostrando la demo
   en el celular ahí mismo. En este nicho la venta se cierra hablando,
   no por anuncio.
3. **Primer cliente con descuento fuerte o gratis** a cambio de ser caso
   de referencia (testimonio + capturas reales de su tienda funcionando).
4. Con 2-3 clientes reales, recién ahí tiene sentido invertir en
   Google/Meta Ads usando el caso de éxito como gancho.
5. **Google Play / App Store es lo último, no lo primero.** Se sube
   cuando ya hay tiendas pidiendo su propia app instalable. Costo: USD 25
   pago único (Google), USD 99/año (Apple).

## Plan de prueba gratuita (mes gratis)

Decisión: ofrecer 1 mes de prueba gratis al lanzar, como gancho comercial.

Condiciones a tener claras antes de ofrecerlo:

- **Requiere backend real (Supabase) funcionando**, no la demo actual en
  memoria — un trial sobre datos que se borran al recargar no sirve.
  Esto depende de completar la fase técnica pendiente (ver `README.md`,
  sección "Pendiente para la siguiente fase").
- El mes gratis tiene costo real para nosotros (tiempo de soporte,
  ayuda a cargar catálogo) aunque no se cobre — vale la pena solo si
  convierte a planes pagos después.
- Sugerencia: pedir tarjeta al inscribirse aunque no se cobre el primer
  mes, para filtrar interesados serios.

## Próximos pasos

1. Terminar la fase de backend real (Supabase) — ver roadmap técnico en
   `README.md`.
2. En paralelo, armar la landing page de ventas con la demo embebida y
   botón de "Prueba gratis 30 días".
3. Validar precios con el primer cliente real antes de fijar tabla
   definitiva.
