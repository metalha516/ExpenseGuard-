import json
import os
import subprocess
import re

project_file = r'C:/Users/metal/.gemini/antigravity/brain/94e35c1f-c9d8-4561-85e7-ed45b81f50c9/.system_generated/steps/40/output.txt'
screens_file = r'C:/Users/metal/.gemini/antigravity/brain/94e35c1f-c9d8-4561-85e7-ed45b81f50c9/.system_generated/steps/44/output.txt'

with open(project_file, 'r', encoding='utf-8') as f:
    project_data = json.load(f)

with open(screens_file, 'r', encoding='utf-8') as f:
    screens_data = json.load(f)

os.makedirs('design_reference/images', exist_ok=True)
os.makedirs('design_reference/code', exist_ok=True)

with open('design_reference/project_metadata.json', 'w', encoding='utf-8') as f:
    json.dump(project_data, f, indent=2)

with open('design_reference/screens_metadata.json', 'w', encoding='utf-8') as f:
    json.dump(screens_data, f, indent=2)

def clean_name(s):
    return re.sub(r'[^\w\-_]', '_', s).strip('_')

screens = screens_data.get('screens', [])
print(f'Total screens found: {len(screens)}')

for s in screens:
    sid = s['name'].split('/')[-1]
    title = clean_name(s.get('title', 'screen'))
    
    if 'screenshot' in s and 'downloadUrl' in s['screenshot']:
        img_url = s['screenshot']['downloadUrl']
        img_path = os.path.join('design_reference', 'images', f'{sid}_{title}.png')
        if not os.path.exists(img_path):
            print(f'Downloading image: {title}...')
            subprocess.run(['curl.exe', '-L', img_url, '-o', img_path], check=True)
            
    if 'htmlCode' in s and 'downloadUrl' in s['htmlCode']:
        html_url = s['htmlCode']['downloadUrl']
        html_path = os.path.join('design_reference', 'code', f'{sid}_{title}.html')
        if not os.path.exists(html_path):
            print(f'Downloading html: {title}...')
            subprocess.run(['curl.exe', '-L', html_url, '-o', html_path], check=True)

print('All assets downloaded successfully!')
