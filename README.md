# AKCIEBI.GE

ქართული ფასდაკლებების პლატფორმა — სტატიკური PWA, Supabase Auth, შეთავაზებების ბაზა და ფოტოატვირთვა.

## ფაილები
- `index.html` — ვებაპლიკაცია
- `manifest.json`, `sw.js`, `icon.svg` — PWA ინსტალაცია და ქეშირება
- `privacy.html` — კონფიდენციალურობის პოლიტიკა
- `supabase-setup.sql` — მონაცემთა ბაზისა და Storage-ის საწყისი კონფიგურაცია

## აუცილებელი ერთჯერადი Supabase კონფიგურაცია
1. გახსენი Supabase Dashboard პროექტისთვის `hmdkcezcpmdtpbajjfli`.
2. გადადი **SQL Editor** → **New query**.
3. ამ რეპოზიტორიიდან გახსენი `supabase-setup.sql`, მთლიანად დააკოპირე და SQL Editor-ში გაუშვი **Run**.
4. გადაამოწმე **Table Editor**-ში, რომ შეიქმნა `public.offers`, ხოლო **Storage**-ში — საჯარო `offer-images` bucket.
5. Authentication → URL Configuration-ში დაამატე საიტის საბოლოო HTTPS მისამართი, როგორც Site URL და Redirect URL. GitHub Pages-ის მისამართი გამოიყენე მას შემდეგ, რაც Pages რეალურად ჩაირთვება.

## გაშვება
GitHub-ის Settings → Pages-ში აირჩიე Deploy from a branch, branch `main`, folder `/ (root)`. შენახვის შემდეგ საიტი გაეშვება GitHub Pages-ის მიერ ნაჩვენებ URL-ზე.

## ფოტოატვირთვა
შესული მომხმარებელი ირჩევს ფოტოს მოწყობილობიდან. დაშვებულია image ტიპის ფაილები მაქსიმუმ 5 MB. ფოტო ინახება `offer-images` bucket-ში მომხმარებლის ID-ის საქაღალდეში. Storage-ის წესები მოცემულია SQL ფაილში.

## Google Play
Play Store-ისთვის საჭიროა საბოლოო HTTPS დომენი, დადასტურებული PWA, Android TWA პაკეტი (AAB), Digital Asset Links-ის `assetlinks.json` ფაილი და Play Console-ის დეველოპერის ანგარიში. AAB-ის ხელმოწერა საჭიროებს საბოლოო package ID-სა და signing key-ს. Play Console-ში აპის მონაცემებისა და დეკლარაციების საბოლოო დადასტურება ანგარიშის მფლობელმა უნდა გააკეთოს.

**მნიშვნელოვანი:** Supabase SQL ჯერ Dashboard-ში უნდა გაეშვას. მხოლოდ GitHub-ში ფაილის დამატება Supabase-ის ცოცხალ მონაცემთა ბაზას ავტომატურად არ ცვლის.
