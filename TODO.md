# IssacVFX — TODO

## Domain & Hosting Setup
- [ ] Add domain to Cloudflare (free plan) — "Add a site" in Cloudflare dashboard
- [ ] Copy the two nameservers Cloudflare gives you
- [ ] Go to Hostinger > domain > DNS/Nameservers > replace with Cloudflare nameservers
- [ ] Wait for propagation (minutes to hours)
- [ ] R2 bucket > Settings > Custom Domains > + Add > set `assets.<yourdomain>.com`
- [ ] Deploy site to Cloudflare Pages

## Current Testing
- [x] Create R2 bucket (`issac-3d-asset`, Asia-Pacific)
- [x] Enable Public Development URL on R2
- [ ] Upload hero video to R2 bucket
- [ ] Update index.html hero video src with R2 public URL
- [ ] Test video playback from R2

## Content (Later)
- [ ] Upload all ~20 portfolio videos to R2
- [ ] Add poster thumbnails for portfolio cards
- [ ] Update portfolio card titles, categories, descriptions
- [ ] Fill in real social links (ArtStation, Instagram, LinkedIn, Behance)
- [ ] Update "Hire Me" mailto with real email
- [ ] Update about/expertise section copy with Issac's actual info
