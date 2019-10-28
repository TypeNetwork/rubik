#!/bin/sh
set -e


echo "Generating Static fonts"
mkdir -p ../fonts
fontmake -m Rubik.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake -m Rubik_Italic.designspace -i -o ttf --output-dir ../fonts/ttf/
fontmake -m Rubik.designspace -i -o otf --output-dir ../fonts/otf/
fontmake -m Rubik_Italic.designspace -i -o otf --output-dir ../fonts/otf/

echo "Generating VFs"
fontmake -m Rubik.designspace -o variable --output-path ../fonts/ttf/Rubik[wght].ttf
fontmake -m Rubik_Italic.designspace -o variable --output-path ../fonts/ttf/Rubik-Italic[wght].ttf

rm -rf master_ufo/ instance_ufo/ instance_ufos/*


echo "Post processing"
ttfs=$(ls ../fonts/ttf/*.ttf)
for ttf in $ttfs
do
	gftools fix-dsig -f $ttf;
	ttfautohint $ttf "$ttf.fix";
	mv "$ttf.fix" $ttf;
done

for ttf in $ttfs
do
	gftools fix-hinting $ttf;
	mv "$ttf.fix" $ttf;
done



vfs=$(ls ../fonts/ttf/*\[wght\].ttf)

echo "Post processing VFs"
for vf in $vfs
do
	gftools fix-dsig -f $vf;
	ttfautohint-vf --stem-width-mode nnn $vf "$vf.fix";
	mv "$vf.fix" $vf;
done



echo "Fixing VF Meta"
for vf in $vfs
do 
	gftools fix-vf-meta $vf ;
	
done

echo "Dropping MVAR"
for vf in $vfs
do
	mv "$vf.fix" $vf;
	ttx -f -x "MVAR" $vf; # Drop MVAR. Table has issue in DW
	rtrip=$(basename -s .ttf $vf)
	new_file=../fonts/ttf/$rtrip.ttx;
	rm $vf;
	ttx $new_file
	rm $new_file
done

echo "Fixing Hinting"
for vf in $vfs
do
	gftools fix-hinting $vf;
	mv "$vf.fix" $vf;
done


echo "Checking TYPOGRAPHIC_SUBFAMILY_NAME (aka f.info.openTypeNamePreferredSubfamilyName) in VFs"
python fixTypographicSubfamilyName.py
