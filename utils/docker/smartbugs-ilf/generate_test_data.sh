for file in $(find $1 -type f -name "*.sol" -printf "/dataset/%P\n")
do
    docker run --rm -v "$(realpath $1)":/dataset -it smartbugs-ilf /workdir/scripts/symbolic.sh $file
done
