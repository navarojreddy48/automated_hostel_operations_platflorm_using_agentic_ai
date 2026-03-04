from pathlib import Path
import re

# Find all JS/JSX files in frontend/src directory
root = Path('frontend/src')
files_updated = []
total_replacements = 0

for file_path in root.rglob('*.jsx'):
    try:
        content = file_path.read_text(encoding='utf-8')
        original_content = content
        
        # Replace relative API URLs with localhost URLs
        # Pattern: fetch('/api/...') or fetch("/api/...")
        content = re.sub(
            r'''fetch\(['"](/api/[^'"]+)['"]\)''',
            r"fetch('http://localhost:5000\1')",
            content
        )
        
        # Pattern: fetch('/api/...', { with POST/PUT/DELETE
        content = re.sub(
            r'''fetch\(['"](/api/[^'"]+)['"],\s*\{''',
            r"fetch('http://localhost:5000\1', {",
            content
        )
        
        # Pattern: fetch(`/api/...`)
        content = re.sub(
            r'''fetch\(`(/api/[^`]+)`\)''',
            r"fetch(`http://localhost:5000\1`)",
            content
        )
        
        # Pattern: fetch(`/api/...`, { with POST/PUT/DELETE
        content = re.sub(
            r'''fetch\(`(/api/[^`]+)`,\s*\{''',
            r"fetch(`http://localhost:5000\1`, {",
            content
        )
        
        # Pattern: new URL('/api/...', ...)
        content = re.sub(
            r'''new URL\(['"](/api/[^'"]+)['"]''',
            r"new URL('http://localhost:5000\1'",
            content
        )
        
        if content != original_content:
            file_path.write_text(content, encoding='utf-8', newline='')
            replacements = len(re.findall(r'http://localhost:5000/api/', content))
            files_updated.append((str(file_path), replacements))
            total_replacements += replacements
            
    except Exception as e:
        print(f"Error processing {file_path}: {e}")

print(f"\nFixed {len(files_updated)} files with {total_replacements} API URL replacements:")
for file, count in files_updated:
    print(f"  {file}: {count} replacements")
