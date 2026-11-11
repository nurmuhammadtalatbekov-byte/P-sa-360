insert into public.test_categories(code,title,description) values
('reading','O‘qish savodxonligi','Matnni tushunish, tahlil va dalilni baholash'),
('math','Matematik savodxonlik','Hayotiy vaziyatlarda matematik fikrlash'),
('science','Tabiiy-ilmiy savodxonlik','Ilmiy hodisalar, dalillar va ma’lumotlar'),
('digital','Raqamli dunyoda ta’lim','Raqamli muhitda axborot bilan ishlash'),
('critical','Tanqidiy fikrlash','Mustaqil diagnostika moduli'),
('problem','Muammo yechish','Mustaqil diagnostika moduli')
on conflict (code) do nothing;

insert into public.test_levels(label,sort_order) values
('Boshlang‘ich',1),('O‘rta',2),('Yuqori',3),('Murakkab',4),('Ekspert',5)
on conflict (sort_order) do nothing;
