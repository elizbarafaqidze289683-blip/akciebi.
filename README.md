<!DOCTYPE html>
<html lang="ka">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AKCIEBI.GE — აქციები და ფასდაკლებები</title>
<style>
*{box-sizing:border-box}
body{margin:0;font-family:Arial,sans-serif;background:#f3f6f5;color:#172b24}
header{background:#087d43;color:white;padding:22px 15px;text-align:center}
header h1{margin:0;font-size:30px}
header p{margin:8px 0 0}
.container{max-width:950px;margin:auto;padding:18px}
.search{width:100%;padding:15px;border:1px solid #ddd;border-radius:12px;font-size:16px}
h2{margin-top:25px}
.regions,.categories{display:flex;gap:10px;flex-wrap:wrap}
button{border:0;padding:12px 18px;border-radius:10px;background:#087d43;color:white;font-size:15px;cursor:pointer}
button.active{background:#064d2c}
.card{background:white;padding:17px;border-radius:14px;margin:12px 0;box-shadow:0 2px 8px #0001}
.card h3{margin:0 0 8px}
.discount{color:#087d43;font-size:23px;font-weight:bold}
footer{text-align:center;padding:25px;color:#777}
</style>
</head>
<body>

<header>
<h1>AKCIEBI.GE</h1>
<p>იპოვე საუკეთესო აქციები ერთ სივრცეში</p>
</header>

<div class="container">

<h2>აირჩიე რეგიონი</h2>
<div class="regions">
<button class="active" onclick="region('საქართველო',this)">🇬🇪 საქართველო</button>
<button onclick="region('ევროპა',this)">🇪🇺 ევროპა</button>
<button onclick="region('ამერიკა',this)">🇺🇸 ამერიკა</button>
</div>

<h2>მოძებნე პროდუქტი</h2>
<input class="search" id="search" placeholder="მაგ: ტელეფონი, ტელევიზორი..." oninput="filter()">

<h2>კატეგორიები</h2>
<div class="categories">
<button onclick="category('ყველა')">ყველა</button>
<button onclick="category('ტექნიკა')">ტექნიკა</button>
<button onclick="category('საკვები')">საკვები</button>
<button onclick="category('ტანსაცმელი')">ტანსაცმელი</button>
<button onclick="category('სახლი')">სახლი</button>
</div>

<h2 id="title">საქართველოს აქციები</h2>
<div id="offers"></div>

</div>

<footer>© 2026 AKCIEBI.GE — ყველა აქცია ერთ სივრცეში</footer>

<script>
let currentRegion='საქართველო';
let currentCategory='ყველა';

let products=[
{name:'ტელევიზორი',shop:'მაგალითი მაღაზია',price:'999 ₾',discount:'-20%',cat:'ტექნიკა',region:'საქართველო'},
{name:'სმარტფონი',shop:'მაგალითი მაღაზია',price:'699 ₾',discount:'-15%',cat:'ტექნიკა',region:'საქართველო'},
{name:'საკვები პროდუქტები',shop:'მაგალითი სუპერმარკეტი',price:'5 ₾',discount:'-10%',cat:'საკვები',region:'საქართველო'},
{name:'ტანსაცმელი',shop:'მაგალითი მაღაზია',price:'49 ₾',discount:'-30%',cat:'ტანსაცმელი',region:'საქართველო'},
{name:'ტელევიზორი',shop:'Sample Store',price:'299 €',discount:'-20%',cat:'ტექნიკა',region:'ევროპა'},
{name:'Smartphone',shop:'Sample Store',price:'399 $',discount:'-15%',cat:'ტექნიკა',region:'ამერიკა'}
];

function show(){
let q=document.getElementById('search').value.toLowerCase();
let list=products.filter(p=>
p.region===currentRegion &&
(currentCategory==='ყველა'||p.cat===currentCategory) &&
p.name.toLowerCase().includes(q)
);
document.getElementById('offers').innerHTML=list.length?
list.map(p=>`<div class="card"><h3>${p.name}</h3><p>${p.shop}</p><div class="discount">${p.discount}</div><b>${p.price}</b></div>`).join(''):
'<p>ამჟამად შეთავაზებები არ არის.</p>';
}

function region(r,btn){
currentRegion=r;
document.querySelectorAll('.regions button').forEach(b=>b.classList.remove('active'));
btn.classList.add('active');
document.getElementById('title').innerText=r+' — აქციები';
show();
}
function category(c){currentCategory=c;show();}
function filter(){show();}
show();
</script>

</body>
</html>
