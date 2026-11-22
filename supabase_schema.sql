-- =======================================================
-- 🗄️ GlowCare AI - Supabase PostgreSQL Schema Script

-- =======================================================

-- 1. Create Products Table
CREATE TABLE IF NOT EXISTS public.products (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    brand TEXT NOT NULL,
    price NUMERIC NOT NULL,
    rating NUMERIC DEFAULT 4.5,
    category TEXT NOT NULL,
    image TEXT NOT NULL,
    description TEXT,
    ingredients JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. Create Orders Table
CREATE TABLE IF NOT EXISTS public.orders (
    id TEXT PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    wilaya TEXT NOT NULL,
    address TEXT NOT NULL,
    subtotal NUMERIC NOT NULL,
    delivery NUMERIC NOT NULL,
    total NUMERIC NOT NULL,
    items JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. Enable Row Level Security (RLS) & Add Public Read / Insert Policies
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

-- Products: Everyone can read products
CREATE POLICY "Public read products" ON public.products
    FOR SELECT USING (true);

-- Orders: Users can read and insert their orders
CREATE POLICY "Public insert orders" ON public.orders
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users read own orders" ON public.orders
    FOR SELECT USING (auth.uid() IS NOT NULL AND user_id = auth.uid());

-- 4. Sample Seed Data for Products (Optional)
INSERT INTO public.products (id, name, brand, price, rating, category, image, description, ingredients)
VALUES
('1', 'Niacinamide 10% + Zinc 1%', 'The Ordinary', 2400, 4.8, 'Skincare', 'https://images.unsplash.com/photo-1620916566398-39f1143ab7be?w=500', 'High-strength vitamin and mineral blemish formula.', '["Niacinamide", "Zinc PCA", "Aqua"]'),
('2', 'Hydrating Facial Cleanser', 'CeraVe', 3600, 4.7, 'Skincare', 'https://images.unsplash.com/photo-1556228720-195a672e8a03?w=500', 'Cleanses and hydrates without disrupting the protective skin barrier.', '["Ceramides", "Hyaluronic Acid"]'),
('3', 'Lash Sensational Mascara', 'Maybelline', 2200, 4.6, 'Makeup', 'https://images.unsplash.com/photo-1631729371254-42c2892f0e6e?w=500', 'Volumizing mascara for full fan effect.', '["Aqua", "Beeswax", "Paraffin"]'),
('4', 'Eau de Parfum Rose Elegance', 'Maison Glow', 5800, 4.9, 'Fragrance', 'https://images.unsplash.com/photo-1592945403244-b3fbafd7f539?w=500', 'Luxurious rose fragrance with floral and warm notes.', '["Alcohol", "Parfum", "Rose Extract"]')
ON CONFLICT (id) DO NOTHING;
