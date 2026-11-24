export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "17.1"
  }
  public: {
    Tables: {
      customer_addresses: {
        Row: {
          address: string
          area: string
          city: string
          created_at: string
          id: string
          is_default: boolean
          label: string
          phone: string
          pincode: string
          recipient_name: string
          user_id: string
        }
        Insert: {
          address: string
          area?: string
          city?: string
          created_at?: string
          id?: string
          is_default?: boolean
          label?: string
          phone: string
          pincode?: string
          recipient_name: string
          user_id: string
        }
        Update: {
          address?: string
          area?: string
          city?: string
          created_at?: string
          id?: string
          is_default?: boolean
          label?: string
          phone?: string
          pincode?: string
          recipient_name?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "customer_addresses_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      design_images: {
        Row: {
          created_at: string
          id: string
          image_kind: string
          item_id: string
          storage_path: string
        }
        Insert: {
          created_at?: string
          id?: string
          image_kind: string
          item_id: string
          storage_path: string
        }
        Update: {
          created_at?: string
          id?: string
          image_kind?: string
          item_id?: string
          storage_path?: string
        }
        Relationships: [
          {
            foreignKeyName: "design_images_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "order_items"
            referencedColumns: ["id"]
          },
        ]
      }
      garment_categories: {
        Row: {
          instructions: string
          is_active: boolean
          measurement_fields: Json
          name: string
          slug: string
          sort_order: number
        }
        Insert: {
          instructions?: string
          is_active?: boolean
          measurement_fields?: Json
          name: string
          slug: string
          sort_order?: number
        }
        Update: {
          instructions?: string
          is_active?: boolean
          measurement_fields?: Json
          name?: string
          slug?: string
          sort_order?: number
        }
        Relationships: []
      }
      measurement_sheets: {
        Row: {
          generated_at: string
          id: string
          item_id: string
          sheet_version: number
          snapshot: Json
        }
        Insert: {
          generated_at?: string
          id?: string
          item_id: string
          sheet_version?: number
          snapshot: Json
        }
        Update: {
          generated_at?: string
          id?: string
          item_id?: string
          sheet_version?: number
          snapshot?: Json
        }
        Relationships: [
          {
            foreignKeyName: "measurement_sheets_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: true
            referencedRelation: "order_items"
            referencedColumns: ["id"]
          },
        ]
      }
      measurements: {
        Row: {
          field_key: string
          id: string
          item_id: string
          label: string
          sort_order: number
          unit: string
          value: string
        }
        Insert: {
          field_key: string
          id?: string
          item_id: string
          label: string
          sort_order?: number
          unit?: string
          value?: string
        }
        Update: {
          field_key?: string
          id?: string
          item_id?: string
          label?: string
          sort_order?: number
          unit?: string
          value?: string
        }
        Relationships: [
          {
            foreignKeyName: "measurements_item_id_fkey"
            columns: ["item_id"]
            isOneToOne: false
            referencedRelation: "order_items"
            referencedColumns: ["id"]
          },
        ]
      }
      order_items: {
        Row: {
          category_slug: string
          created_at: string
          design_description: string
          id: string
          includes_blouse: boolean
          item_number: number
          order_id: string
          quantity: number
          stitching_requirements: string
          unit_price: number | null
        }
        Insert: {
          category_slug: string
          created_at?: string
          design_description?: string
          id?: string
          includes_blouse?: boolean
          item_number: number
          order_id: string
          quantity?: number
          stitching_requirements?: string
          unit_price?: number | null
        }
        Update: {
          category_slug?: string
          created_at?: string
          design_description?: string
          id?: string
          includes_blouse?: boolean
          item_number?: number
          order_id?: string
          quantity?: number
          stitching_requirements?: string
          unit_price?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "order_items_category_slug_fkey"
            columns: ["category_slug"]
            isOneToOne: false
            referencedRelation: "garment_categories"
            referencedColumns: ["slug"]
          },
          {
            foreignKeyName: "order_items_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      order_status_history: {
        Row: {
          changed_by: string | null
          created_at: string
          id: string
          message: string
          order_id: string
          previous_status: string | null
          status: string
        }
        Insert: {
          changed_by?: string | null
          created_at?: string
          id?: string
          message?: string
          order_id: string
          previous_status?: string | null
          status: string
        }
        Update: {
          changed_by?: string | null
          created_at?: string
          id?: string
          message?: string
          order_id?: string
          previous_status?: string | null
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "order_status_history_changed_by_fkey"
            columns: ["changed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "order_status_history_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      orders: {
        Row: {
          advance_amount: number
          courier_charge: number
          created_at: string
          customer_id: string
          customer_instructions: string
          customer_name: string
          customer_phone: string
          delivery_method: string
          expected_completion: string | null
          id: string
          order_code: string
          payment_status: string
          pickup_charge: number
          quoted_total: number | null
          shop_id: string
          status: string
          updated_at: string
        }
        Insert: {
          advance_amount?: number
          courier_charge?: number
          created_at?: string
          customer_id: string
          customer_instructions?: string
          customer_name?: string
          customer_phone?: string
          delivery_method?: string
          expected_completion?: string | null
          id?: string
          order_code?: string
          payment_status?: string
          pickup_charge?: number
          quoted_total?: number | null
          shop_id: string
          status?: string
          updated_at?: string
        }
        Update: {
          advance_amount?: number
          courier_charge?: number
          created_at?: string
          customer_id?: string
          customer_instructions?: string
          customer_name?: string
          customer_phone?: string
          delivery_method?: string
          expected_completion?: string | null
          id?: string
          order_code?: string
          payment_status?: string
          pickup_charge?: number
          quoted_total?: number | null
          shop_id?: string
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "orders_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "orders_shop_id_fkey"
            columns: ["shop_id"]
            isOneToOne: false
            referencedRelation: "tailor_shops"
            referencedColumns: ["id"]
          },
        ]
      }
      payments: {
        Row: {
          amount: number
          confirmed_by: string | null
          created_at: string
          id: string
          method: string
          note: string
          order_id: string
          recorded_by: string
          status: string
        }
        Insert: {
          amount: number
          confirmed_by?: string | null
          created_at?: string
          id?: string
          method: string
          note?: string
          order_id: string
          recorded_by: string
          status?: string
        }
        Update: {
          amount?: number
          confirmed_by?: string | null
          created_at?: string
          id?: string
          method?: string
          note?: string
          order_id?: string
          recorded_by?: string
          status?: string
        }
        Relationships: [
          {
            foreignKeyName: "payments_confirmed_by_fkey"
            columns: ["confirmed_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payments_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: false
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "payments_recorded_by_fkey"
            columns: ["recorded_by"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      pickup_requests: {
        Row: {
          address: string
          area: string
          assigned_person: string
          created_at: string
          id: string
          instructions: string
          order_id: string
          pincode: string
          preferred_date: string | null
          preferred_time: string
          status: string
          updated_at: string
        }
        Insert: {
          address: string
          area?: string
          assigned_person?: string
          created_at?: string
          id?: string
          instructions?: string
          order_id: string
          pincode?: string
          preferred_date?: string | null
          preferred_time?: string
          status?: string
          updated_at?: string
        }
        Update: {
          address?: string
          area?: string
          assigned_person?: string
          created_at?: string
          id?: string
          instructions?: string
          order_id?: string
          pincode?: string
          preferred_date?: string | null
          preferred_time?: string
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "pickup_requests_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: true
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          created_at: string
          display_name: string
          id: string
          phone: string
          preferred_unit: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          display_name?: string
          id: string
          phone?: string
          preferred_unit?: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          display_name?: string
          id?: string
          phone?: string
          preferred_unit?: string
          updated_at?: string
        }
        Relationships: []
      }
      reviews: {
        Row: {
          admin_response: string
          body: string
          created_at: string
          customer_id: string
          id: string
          is_published: boolean
          order_id: string
          photo_path: string | null
          rating: number
          responded_at: string | null
          shop_id: string
        }
        Insert: {
          admin_response?: string
          body?: string
          created_at?: string
          customer_id: string
          id?: string
          is_published?: boolean
          order_id: string
          photo_path?: string | null
          rating: number
          responded_at?: string | null
          shop_id: string
        }
        Update: {
          admin_response?: string
          body?: string
          created_at?: string
          customer_id?: string
          id?: string
          is_published?: boolean
          order_id?: string
          photo_path?: string | null
          rating?: number
          responded_at?: string | null
          shop_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "reviews_customer_id_fkey"
            columns: ["customer_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reviews_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: true
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reviews_shop_id_fkey"
            columns: ["shop_id"]
            isOneToOne: false
            referencedRelation: "tailor_shops"
            referencedColumns: ["id"]
          },
        ]
      }
      shipping_details: {
        Row: {
          id: string
          order_id: string
          outgoing_courier: string
          outgoing_tracking: string
          return_courier: string
          return_tracking: string
          shipping_instructions: string
          status: string
          updated_at: string
        }
        Insert: {
          id?: string
          order_id: string
          outgoing_courier?: string
          outgoing_tracking?: string
          return_courier?: string
          return_tracking?: string
          shipping_instructions?: string
          status?: string
          updated_at?: string
        }
        Update: {
          id?: string
          order_id?: string
          outgoing_courier?: string
          outgoing_tracking?: string
          return_courier?: string
          return_tracking?: string
          shipping_instructions?: string
          status?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "shipping_details_order_id_fkey"
            columns: ["order_id"]
            isOneToOne: true
            referencedRelation: "orders"
            referencedColumns: ["id"]
          },
        ]
      }
      shop_designs: {
        Row: {
          category_slug: string | null
          created_at: string
          description: string
          id: string
          name: string
          shop_id: string
          stitching_price: number
          storage_path: string | null
        }
        Insert: {
          category_slug?: string | null
          created_at?: string
          description?: string
          id?: string
          name: string
          shop_id: string
          stitching_price?: number
          storage_path?: string | null
        }
        Update: {
          category_slug?: string | null
          created_at?: string
          description?: string
          id?: string
          name?: string
          shop_id?: string
          stitching_price?: number
          storage_path?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "shop_designs_category_slug_fkey"
            columns: ["category_slug"]
            isOneToOne: false
            referencedRelation: "garment_categories"
            referencedColumns: ["slug"]
          },
          {
            foreignKeyName: "shop_designs_shop_id_fkey"
            columns: ["shop_id"]
            isOneToOne: false
            referencedRelation: "tailor_shops"
            referencedColumns: ["id"]
          },
        ]
      }
      shop_gallery: {
        Row: {
          caption: string
          created_at: string
          id: string
          is_cover: boolean
          shop_id: string
          storage_path: string
        }
        Insert: {
          caption?: string
          created_at?: string
          id?: string
          is_cover?: boolean
          shop_id: string
          storage_path: string
        }
        Update: {
          caption?: string
          created_at?: string
          id?: string
          is_cover?: boolean
          shop_id?: string
          storage_path?: string
        }
        Relationships: [
          {
            foreignKeyName: "shop_gallery_shop_id_fkey"
            columns: ["shop_id"]
            isOneToOne: false
            referencedRelation: "tailor_shops"
            referencedColumns: ["id"]
          },
        ]
      }
      shop_services: {
        Row: {
          category_slug: string | null
          created_at: string
          id: string
          service_name: string
          shop_id: string
          starting_price: number
        }
        Insert: {
          category_slug?: string | null
          created_at?: string
          id?: string
          service_name: string
          shop_id: string
          starting_price?: number
        }
        Update: {
          category_slug?: string | null
          created_at?: string
          id?: string
          service_name?: string
          shop_id?: string
          starting_price?: number
        }
        Relationships: [
          {
            foreignKeyName: "shop_services_category_slug_fkey"
            columns: ["category_slug"]
            isOneToOne: false
            referencedRelation: "garment_categories"
            referencedColumns: ["slug"]
          },
          {
            foreignKeyName: "shop_services_shop_id_fkey"
            columns: ["shop_id"]
            isOneToOne: false
            referencedRelation: "tailor_shops"
            referencedColumns: ["id"]
          },
        ]
      }
      tailor_shops: {
        Row: {
          address: string
          area: string
          city: string
          cover_path: string | null
          created_at: string
          description: string
          id: string
          is_demo: boolean
          latitude: number | null
          longitude: number | null
          name: string
          offers_delivery: boolean
          owner_id: string
          owner_name: string
          phone: string
          pickup_fee: number
          pincode: string
          price_max: number
          price_min: number
          status: string
          supports_shipping: boolean
          updated_at: string
        }
        Insert: {
          address?: string
          area?: string
          city?: string
          cover_path?: string | null
          created_at?: string
          description?: string
          id?: string
          is_demo?: boolean
          latitude?: number | null
          longitude?: number | null
          name: string
          offers_delivery?: boolean
          owner_id: string
          owner_name?: string
          phone?: string
          pickup_fee?: number
          pincode?: string
          price_max?: number
          price_min?: number
          status?: string
          supports_shipping?: boolean
          updated_at?: string
        }
        Update: {
          address?: string
          area?: string
          city?: string
          cover_path?: string | null
          created_at?: string
          description?: string
          id?: string
          is_demo?: boolean
          latitude?: number | null
          longitude?: number | null
          name?: string
          offers_delivery?: boolean
          owner_id?: string
          owner_name?: string
          phone?: string
          pickup_fee?: number
          pincode?: string
          price_max?: number
          price_min?: number
          status?: string
          supports_shipping?: boolean
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "tailor_shops_owner_id_fkey"
            columns: ["owner_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          role: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          role: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          role?: string
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      current_user_owns_shop: { Args: { _shop_id: string }; Returns: boolean }
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {},
  },
} as const
