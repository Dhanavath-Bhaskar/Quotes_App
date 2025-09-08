import json
from collections import defaultdict

# Path to your JSON file
json_path = 'quotes_seed.json'

with open(json_path, 'r', encoding='utf-8') as f:
    quotes = json.load(f)

category_indices = defaultdict(list)

# Collect all indices for each category
for idx, quote in enumerate(quotes):
    cat = quote.get("kCategory")
    if cat:
        category_indices[cat].append(idx)

# Prepare summary: category, count, start, end
summary = []
for cat, indices in category_indices.items():
    summary.append({
        'category': cat,
        'count': len(indices),
        'start': indices[0],
        'end': indices[-1]
    })

# Sort by count (descending), then alphabetically
summary.sort(key=lambda x: (-x['count'], x['category']))

# Print the results
for item in summary:
    print(f"{item['category']}: count={item['count']}, start={item['start']}, end={item['end']}")
