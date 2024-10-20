
count=0

for file in *; do
    mv "$file" "img_$count.${file##*.}"
    count=$((count+1))
done
