CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text NOT NULL DEFAULT '',
  phone text NOT NULL DEFAULT '',
  preferred_unit text NOT NULL DEFAULT 'in' CHECK (preferred_unit IN ('in', 'cm')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, UPDATE ON public.profiles TO authenticated;
GRANT ALL ON public.profiles TO service_role;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('customer', 'tailor_admin')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, role)
);
GRANT SELECT ON public.user_roles TO authenticated;
GRANT ALL ON public.user_roles TO service_role;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.customer_addresses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  label text NOT NULL DEFAULT 'Home',
  recipient_name text NOT NULL,
  phone text NOT NULL,
  address text NOT NULL,
  area text NOT NULL DEFAULT '',
  city text NOT NULL DEFAULT '',
  pincode text NOT NULL DEFAULT '',
  is_default boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.customer_addresses TO authenticated;
GRANT ALL ON public.customer_addresses TO service_role;
ALTER TABLE public.customer_addresses ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.garment_categories (
  slug text PRIMARY KEY,
  name text NOT NULL,
  measurement_fields jsonb NOT NULL DEFAULT '[]'::jsonb,
  instructions text NOT NULL DEFAULT '',
  is_active boolean NOT NULL DEFAULT true,
  sort_order integer NOT NULL DEFAULT 0
);
GRANT SELECT ON public.garment_categories TO anon, authenticated;
GRANT ALL ON public.garment_categories TO service_role;
ALTER TABLE public.garment_categories ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.tailor_shops (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  name text NOT NULL,
  owner_name text NOT NULL DEFAULT '',
  phone text NOT NULL DEFAULT '',
  address text NOT NULL DEFAULT '',
  area text NOT NULL DEFAULT '',
  city text NOT NULL DEFAULT '',
  pincode text NOT NULL DEFAULT '',
  latitude numeric(9,6),
  longitude numeric(9,6),
  description text NOT NULL DEFAULT '',
  price_min integer NOT NULL DEFAULT 0 CHECK (price_min >= 0),
  price_max integer NOT NULL DEFAULT 0 CHECK (price_max >= price_min),
  supports_shipping boolean NOT NULL DEFAULT false,
  offers_delivery boolean NOT NULL DEFAULT false,
  pickup_fee integer NOT NULL DEFAULT 0 CHECK (pickup_fee = 0),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
  cover_path text,
  is_demo boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
  CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);
GRANT SELECT ON public.tailor_shops TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.tailor_shops TO authenticated;
GRANT ALL ON public.tailor_shops TO service_role;
ALTER TABLE public.tailor_shops ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.shop_services (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.tailor_shops(id) ON DELETE CASCADE,
  service_name text NOT NULL,
  category_slug text REFERENCES public.garment_categories(slug) ON DELETE SET NULL,
  starting_price integer NOT NULL DEFAULT 0 CHECK (starting_price >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (shop_id, service_name)
);
GRANT SELECT ON public.shop_services TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.shop_services TO authenticated;
GRANT ALL ON public.shop_services TO service_role;
ALTER TABLE public.shop_services ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.shop_gallery (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.tailor_shops(id) ON DELETE CASCADE,
  storage_path text NOT NULL,
  caption text NOT NULL DEFAULT '',
  is_cover boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.shop_gallery TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.shop_gallery TO authenticated;
GRANT ALL ON public.shop_gallery TO service_role;
ALTER TABLE public.shop_gallery ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.shop_designs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.tailor_shops(id) ON DELETE CASCADE,
  category_slug text REFERENCES public.garment_categories(slug) ON DELETE SET NULL,
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  stitching_price integer NOT NULL DEFAULT 0 CHECK (stitching_price >= 0),
  storage_path text,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.shop_designs TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.shop_designs TO authenticated;
GRANT ALL ON public.shop_designs TO service_role;
ALTER TABLE public.shop_designs ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_code text NOT NULL UNIQUE DEFAULT ('ST-' || upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 8))),
  customer_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  shop_id uuid NOT NULL REFERENCES public.tailor_shops(id) ON DELETE RESTRICT,
  customer_name text NOT NULL DEFAULT '',
  customer_phone text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'order_placed' CHECK (status IN ('order_placed', 'order_confirmed', 'stitching_in_progress', 'ready_for_delivery', 'delivered', 'rejected')),
  delivery_method text NOT NULL DEFAULT 'shop_collection' CHECK (delivery_method IN ('home_pickup', 'online_shipping', 'shop_collection', 'shop_delivery')),
  customer_instructions text NOT NULL DEFAULT '',
  expected_completion date,
  quoted_total integer CHECK (quoted_total IS NULL OR quoted_total >= 0),
  advance_amount integer NOT NULL DEFAULT 0 CHECK (advance_amount >= 0),
  courier_charge integer NOT NULL DEFAULT 0 CHECK (courier_charge >= 0),
  pickup_charge integer NOT NULL DEFAULT 0 CHECK (pickup_charge = 0),
  payment_status text NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'advance_paid', 'partially_paid', 'fully_paid')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.orders TO authenticated;
GRANT UPDATE (status, expected_completion, quoted_total, advance_amount, courier_charge, payment_status) ON public.orders TO authenticated;
GRANT ALL ON public.orders TO service_role;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  item_number integer NOT NULL CHECK (item_number > 0),
  category_slug text NOT NULL REFERENCES public.garment_categories(slug),
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity > 0),
  design_description text NOT NULL DEFAULT '',
  stitching_requirements text NOT NULL DEFAULT '',
  includes_blouse boolean NOT NULL DEFAULT false,
  unit_price integer CHECK (unit_price IS NULL OR unit_price >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (order_id, item_number)
);
GRANT SELECT, INSERT ON public.order_items TO authenticated;
GRANT UPDATE (unit_price, stitching_requirements) ON public.order_items TO authenticated;
GRANT ALL ON public.order_items TO service_role;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.design_images (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id uuid NOT NULL REFERENCES public.order_items(id) ON DELETE CASCADE,
  image_kind text NOT NULL CHECK (image_kind IN ('design_reference', 'actual_fabric')),
  storage_path text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (item_id, image_kind)
);
GRANT SELECT, INSERT, UPDATE, DELETE ON public.design_images TO authenticated;
GRANT ALL ON public.design_images TO service_role;
ALTER TABLE public.design_images ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.measurements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id uuid NOT NULL REFERENCES public.order_items(id) ON DELETE CASCADE,
  field_key text NOT NULL,
  label text NOT NULL,
  value text NOT NULL DEFAULT '',
  unit text NOT NULL DEFAULT 'in' CHECK (unit IN ('in', 'cm')),
  sort_order integer NOT NULL DEFAULT 0,
  UNIQUE (item_id, field_key)
);
GRANT SELECT, INSERT ON public.measurements TO authenticated;
GRANT ALL ON public.measurements TO service_role;
ALTER TABLE public.measurements ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.measurement_sheets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  item_id uuid NOT NULL UNIQUE REFERENCES public.order_items(id) ON DELETE CASCADE,
  snapshot jsonb NOT NULL,
  sheet_version integer NOT NULL DEFAULT 1,
  generated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.measurement_sheets TO authenticated;
GRANT ALL ON public.measurement_sheets TO service_role;
ALTER TABLE public.measurement_sheets ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.shipping_details (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL UNIQUE REFERENCES public.orders(id) ON DELETE CASCADE,
  outgoing_courier text NOT NULL DEFAULT '',
  outgoing_tracking text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'shipping_requested' CHECK (status IN ('shipping_requested', 'accepted', 'shipped_by_customer', 'received_at_shop', 'stitching_in_progress', 'return_shipped', 'delivered', 'rejected')),
  return_courier text NOT NULL DEFAULT '',
  return_tracking text NOT NULL DEFAULT '',
  shipping_instructions text NOT NULL DEFAULT '',
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT, UPDATE ON public.shipping_details TO authenticated;
GRANT ALL ON public.shipping_details TO service_role;
ALTER TABLE public.shipping_details ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.pickup_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL UNIQUE REFERENCES public.orders(id) ON DELETE CASCADE,
  address text NOT NULL,
  area text NOT NULL DEFAULT '',
  pincode text NOT NULL DEFAULT '',
  preferred_date date,
  preferred_time text NOT NULL DEFAULT '',
  instructions text NOT NULL DEFAULT '',
  assigned_person text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'pickup_requested' CHECK (status IN ('pickup_requested', 'accepted', 'pickup_scheduled', 'garment_collected', 'stitching_in_progress', 'ready_for_collection', 'collected', 'rejected')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.pickup_requests TO authenticated;
GRANT UPDATE (preferred_date, preferred_time, instructions, assigned_person, status) ON public.pickup_requests TO authenticated;
GRANT ALL ON public.pickup_requests TO service_role;
ALTER TABLE public.pickup_requests ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  amount integer NOT NULL CHECK (amount > 0),
  method text NOT NULL CHECK (method IN ('cash', 'upi')),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'rejected')),
  note text NOT NULL DEFAULT '',
  recorded_by uuid NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  confirmed_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT, INSERT ON public.payments TO authenticated;
GRANT UPDATE (status, confirmed_by) ON public.payments TO authenticated;
GRANT ALL ON public.payments TO service_role;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  shop_id uuid NOT NULL REFERENCES public.tailor_shops(id) ON DELETE CASCADE,
  order_id uuid NOT NULL UNIQUE REFERENCES public.orders(id) ON DELETE CASCADE,
  customer_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  rating integer NOT NULL CHECK (rating BETWEEN 1 AND 5),
  body text NOT NULL DEFAULT '',
  photo_path text,
  admin_response text NOT NULL DEFAULT '',
  responded_at timestamptz,
  is_published boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.reviews TO anon, authenticated;
GRANT INSERT ON public.reviews TO authenticated;
GRANT UPDATE (admin_response, responded_at) ON public.reviews TO authenticated;
GRANT ALL ON public.reviews TO service_role;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

CREATE TABLE public.order_status_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  previous_status text,
  status text NOT NULL,
  message text NOT NULL DEFAULT '',
  changed_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);
GRANT SELECT ON public.order_status_history TO authenticated;
GRANT ALL ON public.order_status_history TO service_role;
ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;

CREATE INDEX tailor_shops_area_city_idx ON public.tailor_shops (lower(city), lower(area));
CREATE INDEX tailor_shops_pincode_idx ON public.tailor_shops (pincode);
CREATE INDEX orders_customer_created_idx ON public.orders (customer_id, created_at DESC);
CREATE INDEX orders_shop_status_idx ON public.orders (shop_id, status, created_at DESC);
CREATE INDEX order_items_order_idx ON public.order_items (order_id, item_number);
CREATE INDEX measurements_item_idx ON public.measurements (item_id, sort_order);
CREATE INDEX payments_order_idx ON public.payments (order_id, created_at DESC);
CREATE INDEX reviews_shop_idx ON public.reviews (shop_id, created_at DESC);

CREATE OR REPLACE FUNCTION public.current_user_owns_shop(_shop_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.tailor_shops
    WHERE id = _shop_id AND owner_id = auth.uid()
  );
$$;
REVOKE ALL ON FUNCTION public.current_user_owns_shop(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.current_user_owns_shop(uuid) TO authenticated;

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, display_name, phone)
  VALUES (
    NEW.id,
    COALESCE(NULLIF(NEW.raw_user_meta_data->>'full_name', ''), NULLIF(NEW.raw_user_meta_data->>'name', ''), NULLIF(split_part(COALESCE(NEW.email, ''), '@', 1), ''), 'New customer'),
    COALESCE(NEW.raw_user_meta_data->>'phone', '')
  )
  ON CONFLICT (id) DO NOTHING;
  INSERT INTO public.user_roles (user_id, role) VALUES (NEW.id, 'customer')
  ON CONFLICT (user_id, role) DO NOTHING;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.handle_new_user() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

CREATE OR REPLACE FUNCTION public.assign_tailor_admin_role()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.user_roles (user_id, role) VALUES (NEW.owner_id, 'tailor_admin')
  ON CONFLICT (user_id, role) DO NOTHING;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.assign_tailor_admin_role() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER tailor_shop_assign_admin_role
AFTER INSERT ON public.tailor_shops
FOR EACH ROW EXECUTE FUNCTION public.assign_tailor_admin_role();

CREATE OR REPLACE FUNCTION public.record_order_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO public.order_status_history (order_id, previous_status, status, changed_by)
    VALUES (NEW.id, NULL, NEW.status, auth.uid());
  ELSIF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO public.order_status_history (order_id, previous_status, status, changed_by)
    VALUES (NEW.id, OLD.status, NEW.status, auth.uid());
  END IF;
  RETURN NEW;
END;
$$;
REVOKE ALL ON FUNCTION public.record_order_status_change() FROM PUBLIC, anon, authenticated;

CREATE TRIGGER order_status_history_trigger
AFTER INSERT OR UPDATE OF status ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.record_order_status_change();

CREATE POLICY profiles_select_own ON public.profiles FOR SELECT TO authenticated USING (id = auth.uid());
CREATE POLICY profiles_update_own ON public.profiles FOR UPDATE TO authenticated USING (id = auth.uid()) WITH CHECK (id = auth.uid());
CREATE POLICY roles_select_own ON public.user_roles FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY addresses_select_own ON public.customer_addresses FOR SELECT TO authenticated USING (user_id = auth.uid());
CREATE POLICY addresses_insert_own ON public.customer_addresses FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY addresses_update_own ON public.customer_addresses FOR UPDATE TO authenticated USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY addresses_delete_own ON public.customer_addresses FOR DELETE TO authenticated USING (user_id = auth.uid());
CREATE POLICY categories_public_read ON public.garment_categories FOR SELECT TO anon, authenticated USING (is_active);

CREATE POLICY shops_public_read ON public.tailor_shops FOR SELECT TO anon, authenticated USING (status = 'active' OR owner_id = auth.uid());
CREATE POLICY shops_insert_own ON public.tailor_shops FOR INSERT TO authenticated WITH CHECK (owner_id = auth.uid());
CREATE POLICY shops_update_own ON public.tailor_shops FOR UPDATE TO authenticated USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());
CREATE POLICY shops_delete_own ON public.tailor_shops FOR DELETE TO authenticated USING (owner_id = auth.uid());

CREATE POLICY services_public_read ON public.shop_services FOR SELECT TO anon, authenticated USING (EXISTS (SELECT 1 FROM public.tailor_shops s WHERE s.id = shop_id AND (s.status = 'active' OR s.owner_id = auth.uid())));
CREATE POLICY services_manage_own ON public.shop_services FOR INSERT TO authenticated WITH CHECK (public.current_user_owns_shop(shop_id));
CREATE POLICY services_update_own ON public.shop_services FOR UPDATE TO authenticated USING (public.current_user_owns_shop(shop_id)) WITH CHECK (public.current_user_owns_shop(shop_id));
CREATE POLICY services_delete_own ON public.shop_services FOR DELETE TO authenticated USING (public.current_user_owns_shop(shop_id));

CREATE POLICY gallery_public_read ON public.shop_gallery FOR SELECT TO anon, authenticated USING (EXISTS (SELECT 1 FROM public.tailor_shops s WHERE s.id = shop_id AND (s.status = 'active' OR s.owner_id = auth.uid())));
CREATE POLICY gallery_manage_own ON public.shop_gallery FOR INSERT TO authenticated WITH CHECK (public.current_user_owns_shop(shop_id));
CREATE POLICY gallery_update_own ON public.shop_gallery FOR UPDATE TO authenticated USING (public.current_user_owns_shop(shop_id)) WITH CHECK (public.current_user_owns_shop(shop_id));
CREATE POLICY gallery_delete_own ON public.shop_gallery FOR DELETE TO authenticated USING (public.current_user_owns_shop(shop_id));

CREATE POLICY designs_public_read ON public.shop_designs FOR SELECT TO anon, authenticated USING (EXISTS (SELECT 1 FROM public.tailor_shops s WHERE s.id = shop_id AND (s.status = 'active' OR s.owner_id = auth.uid())));
CREATE POLICY designs_manage_own ON public.shop_designs FOR INSERT TO authenticated WITH CHECK (public.current_user_owns_shop(shop_id));
CREATE POLICY designs_update_own ON public.shop_designs FOR UPDATE TO authenticated USING (public.current_user_owns_shop(shop_id)) WITH CHECK (public.current_user_owns_shop(shop_id));
CREATE POLICY designs_delete_own ON public.shop_designs FOR DELETE TO authenticated USING (public.current_user_owns_shop(shop_id));

CREATE POLICY orders_read_participant ON public.orders FOR SELECT TO authenticated USING (customer_id = auth.uid() OR public.current_user_owns_shop(shop_id));
CREATE POLICY orders_customer_create ON public.orders FOR INSERT TO authenticated WITH CHECK (customer_id = auth.uid() AND status = 'order_placed' AND pickup_charge = 0 AND payment_status = 'pending');
CREATE POLICY orders_shop_update ON public.orders FOR UPDATE TO authenticated USING (public.current_user_owns_shop(shop_id)) WITH CHECK (public.current_user_owns_shop(shop_id));

CREATE POLICY order_items_read_participant ON public.order_items FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND (o.customer_id = auth.uid() OR public.current_user_owns_shop(o.shop_id))));
CREATE POLICY order_items_customer_create ON public.order_items FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.customer_id = auth.uid()));
CREATE POLICY order_items_shop_update ON public.order_items FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.current_user_owns_shop(o.shop_id))) WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.current_user_owns_shop(o.shop_id)));

CREATE POLICY images_read_participant ON public.design_images FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.order_items i JOIN public.orders o ON o.id = i.order_id WHERE i.id = item_id AND (o.customer_id = auth.uid() OR public.current_user_owns_shop(o.shop_id))));
CREATE POLICY images_manage_customer ON public.design_images FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.order_items i JOIN public.orders o ON o.id = i.order_id WHERE i.id = item_id AND o.customer_id = auth.uid()));
CREATE POLICY images_update_customer ON public.design_images FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.order_items i JOIN public.orders o ON o.id = i.order_id WHERE i.id = item_id AND o.customer_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.order_items i JOIN public.orders o ON o.id = i.order_id WHERE i.id = item_id AND o.customer_id = auth.uid()));
CREATE POLICY images_delete_customer ON public.design_images FOR DELETE TO authenticated USING (EXISTS (SELECT 1 FROM public.order_items i JOIN public.orders o ON o.id = i.order_id WHERE i.id = item_id AND o.customer_id = auth.uid()));

CREATE POLICY measurements_read_participant ON public.measurements FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.order_items i JOIN public.orders o ON o.id = i.order_id WHERE i.id = item_id AND (o.customer_id = auth.uid() OR public.current_user_owns_shop(o.shop_id))));
CREATE POLICY measurements_customer_create ON public.measurements FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.order_items i JOIN public.orders o ON o.id = i.order_id WHERE i.id = item_id AND o.customer_id = auth.uid()));
CREATE POLICY sheets_read_participant ON public.measurement_sheets FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.order_items i JOIN public.orders o ON o.id = i.order_id WHERE i.id = item_id AND (o.customer_id = auth.uid() OR public.current_user_owns_shop(o.shop_id))));
CREATE POLICY sheets_customer_create ON public.measurement_sheets FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.order_items i JOIN public.orders o ON o.id = i.order_id WHERE i.id = item_id AND o.customer_id = auth.uid()));

CREATE POLICY shipping_read_participant ON public.shipping_details FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND (o.customer_id = auth.uid() OR public.current_user_owns_shop(o.shop_id))));
CREATE POLICY shipping_customer_create ON public.shipping_details FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.customer_id = auth.uid()));
CREATE POLICY shipping_update_participant ON public.shipping_details FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND (o.customer_id = auth.uid() OR public.current_user_owns_shop(o.shop_id)))) WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND (o.customer_id = auth.uid() OR public.current_user_owns_shop(o.shop_id))));

CREATE POLICY pickup_read_participant ON public.pickup_requests FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND (o.customer_id = auth.uid() OR public.current_user_owns_shop(o.shop_id))));
CREATE POLICY pickup_customer_create ON public.pickup_requests FOR INSERT TO authenticated WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.customer_id = auth.uid() AND o.delivery_method = 'home_pickup'));
CREATE POLICY pickup_shop_update ON public.pickup_requests FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.current_user_owns_shop(o.shop_id))) WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.current_user_owns_shop(o.shop_id)));

CREATE POLICY payments_read_participant ON public.payments FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND (o.customer_id = auth.uid() OR public.current_user_owns_shop(o.shop_id))));
CREATE POLICY payments_customer_create ON public.payments FOR INSERT TO authenticated WITH CHECK (recorded_by = auth.uid() AND status = 'pending' AND EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.customer_id = auth.uid()));
CREATE POLICY payments_shop_create ON public.payments FOR INSERT TO authenticated WITH CHECK (recorded_by = auth.uid() AND EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.current_user_owns_shop(o.shop_id)));
CREATE POLICY payments_shop_update ON public.payments FOR UPDATE TO authenticated USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.current_user_owns_shop(o.shop_id))) WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.current_user_owns_shop(o.shop_id)));

CREATE POLICY reviews_public_read ON public.reviews FOR SELECT TO anon, authenticated USING (is_published OR customer_id = auth.uid() OR public.current_user_owns_shop(shop_id));
CREATE POLICY reviews_customer_create ON public.reviews FOR INSERT TO authenticated WITH CHECK (customer_id = auth.uid() AND EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND o.shop_id = shop_id AND o.customer_id = auth.uid() AND o.status = 'delivered'));
CREATE POLICY reviews_shop_reply ON public.reviews FOR UPDATE TO authenticated USING (public.current_user_owns_shop(shop_id)) WITH CHECK (public.current_user_owns_shop(shop_id));

CREATE POLICY history_read_participant ON public.order_status_history FOR SELECT TO authenticated USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND (o.customer_id = auth.uid() OR public.current_user_owns_shop(o.shop_id))));

CREATE POLICY order_images_read_participant ON storage.objects FOR SELECT TO authenticated USING (
  bucket_id = 'tailoring-order-images' AND (
    (storage.foldername(name))[1] = auth.uid()::text OR EXISTS (
      SELECT 1 FROM public.orders o
      WHERE o.id::text = (storage.foldername(name))[2]
        AND public.current_user_owns_shop(o.shop_id)
    )
  )
);
CREATE POLICY order_images_insert_customer ON storage.objects FOR INSERT TO authenticated WITH CHECK (
  bucket_id = 'tailoring-order-images'
  AND (storage.foldername(name))[1] = auth.uid()::text
  AND EXISTS (
    SELECT 1 FROM public.orders o
    WHERE o.id::text = (storage.foldername(name))[2]
      AND o.customer_id = auth.uid()
  )
);
CREATE POLICY order_images_update_customer ON storage.objects FOR UPDATE TO authenticated USING (
  bucket_id = 'tailoring-order-images' AND (storage.foldername(name))[1] = auth.uid()::text
) WITH CHECK (
  bucket_id = 'tailoring-order-images' AND (storage.foldername(name))[1] = auth.uid()::text
);
CREATE POLICY order_images_delete_customer ON storage.objects FOR DELETE TO authenticated USING (
  bucket_id = 'tailoring-order-images' AND (storage.foldername(name))[1] = auth.uid()::text
);

CREATE POLICY shop_media_public_read ON storage.objects FOR SELECT TO anon, authenticated USING (
  bucket_id = 'tailoring-shop-media' AND EXISTS (
    SELECT 1 FROM public.tailor_shops s
    WHERE s.id::text = (storage.foldername(name))[2] AND s.status = 'active'
  )
);
CREATE POLICY shop_media_owner_read ON storage.objects FOR SELECT TO authenticated USING (
  bucket_id = 'tailoring-shop-media' AND public.current_user_owns_shop(NULLIF((storage.foldername(name))[2], '')::uuid)
);
CREATE POLICY shop_media_owner_insert ON storage.objects FOR INSERT TO authenticated WITH CHECK (
  bucket_id = 'tailoring-shop-media'
  AND (storage.foldername(name))[1] = auth.uid()::text
  AND public.current_user_owns_shop(NULLIF((storage.foldername(name))[2], '')::uuid)
);
CREATE POLICY shop_media_owner_update ON storage.objects FOR UPDATE TO authenticated USING (
  bucket_id = 'tailoring-shop-media'
  AND (storage.foldername(name))[1] = auth.uid()::text
  AND public.current_user_owns_shop(NULLIF((storage.foldername(name))[2], '')::uuid)
) WITH CHECK (
  bucket_id = 'tailoring-shop-media'
  AND (storage.foldername(name))[1] = auth.uid()::text
  AND public.current_user_owns_shop(NULLIF((storage.foldername(name))[2], '')::uuid)
);
CREATE POLICY shop_media_owner_delete ON storage.objects FOR DELETE TO authenticated USING (
  bucket_id = 'tailoring-shop-media'
  AND (storage.foldername(name))[1] = auth.uid()::text
  AND public.current_user_owns_shop(NULLIF((storage.foldername(name))[2], '')::uuid)
);