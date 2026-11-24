# Smart Tailoring Management System

## What will be built
- A real tailoring-order application for customers and tailor-shop administrators, branded **Smart Tailoring Management System**.
- Customer flow for finding shops, creating an order with multiple garments, separate reference/fabric uploads, category-specific measurements, printable measurement sheets, delivery or free pickup, payment records, and order tracking.
- Tailor workspace for shop/service details, incoming orders, per-item pricing, completion dates, stitching/shipping/pickup updates, payment records, and basic shop statistics.
- Responsive boutique styling using the exact cream, sage, dusty-rose, dark-brown, and soft-white colors in your brief.

## How it will work
- Use this project's supported React/TanStack Start application and Lovable Cloud for authentication, persistent records, and uploads. The brief names Flask and MySQL, but those are not supported by this hosted project template; there will not be a separate Flask/MySQL/local-install deliverable.
- Keep customer records and tailor-admin roles protected; implement role checks with server-side data rules. Authentication setup waits for your answer about customer profile records.
- Preserve each garment's images, measurements, price, quantity, and generated sheet independently. Store home pickup at exactly ₹0, and never represent an unconfigured payment gateway as a completed payment.
- Use Google Maps Platform for shop discovery; connection setup will be requested when implementation reaches that feature. Shop names, addresses, and other business facts will be entered by shop owners rather than invented.

## Technical details
- Build the supported hosted app, not a second framework or database. Use database migrations and access policies for persistent workflows; use Storage for uploads.
- Generate category-specific measurement diagrams as downloadable sheets from exact entered values, with blank values shown as not provided.
- Keep payment handling as cash/UPI payment records unless a real payment integration is configured.
