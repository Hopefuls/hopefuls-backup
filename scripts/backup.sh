# copyright hopefuls.de 2023

backup_folder="/opt/backups"
data_folder="/home/docker"

# loop through the folders in the /home directory, print them each out, only do this to the first 3 folders

# create a variable to count the number of folders we have looped through
i=0


backup_start_date=$(date +%Y-%m-%d-%H%M%S)

# create folder, use the backup_folder variable
mkdir -p $backup_folder/$backup_start_date

echo "HopefulsDE Backup Script" > $backup_folder/$backup_start_date/backupinfo.txt
echo "Started at: $backup_start_date" >> $backup_folder/$backup_start_date/backupinfo.txt
# create a newline
echo "" >> $backup_folder/$backup_start_date/backupinfo.txt

for folder in $data_folder/*;
do
    # check if the folder is a directory
    if [ ! -d "$folder" ]; then
        continue
    fi
    foldername=$(basename $folder)
    # zip the folder and save it in the /home/scripttest/backups folder
    # create a folder named the following format: YYYY-MM-DD-HHMMSS
    # the folder name is the current date and time
    # save the zip into the folder
    
    # add a single file called "backupinfo.txt" to the zip
    # the file should contain the following information:
    # the name of the folder
    # the full path of the folder
    # the original size of the folder
    # the time it took to zip the folder

    folder_full_path=$(realpath $folder)
    folder_original_size=$(du -sh $folder | awk '{print $1}')
    echo "Zipping folder $foldername (path: $folder)"

    # get the current date and time
    # format it as YYYY-MM-DD-HHMMSS
    # save it into a variable
    # create a folder with the date and time, if the folder already exists, ignore
    time_start=$(date +%s)
    # zip the folder, do not include the parents folder, compress it to the smallest size possible, save it in the /home/scripttest/backups folder
    # use multiple threads to speed up the process (use 4 threads)
    tar -cf $backup_folder/$backup_start_date/$foldername.zip.xz $folder_full_path/* --use-compress-program="xz -T 4"

    time_end=$(date +%s)
    # add a single file called "backupinfo.txt" to the zip
    # the file should contain the following information:
    # the name of the folder
    # the full path of the folder
    # the original size of the folder
    # the time it took to zip the folder
    time_taken=$(($time_end - $time_start))
    # create the file
    # write the information into the file
    # add the file to the zip
    echo "  Backup /$foldername.zip.xz" >> $backup_folder/$backup_start_date/backupinfo.txt
    echo "      Time taken: $time_taken" >> $backup_folder/$backup_start_date/backupinfo.txt
    echo "      Folder name: $foldername" >> $backup_folder/$backup_start_date/backupinfo.txt
    echo "      Folder full path: $folder_full_path" >> $backup_folder/$backup_start_date/backupinfo.txt
    echo "      Folder original size: $folder_original_size" >> $backup_folder/$backup_start_date/backupinfo.txt
    echo "" >> $backup_folder/$backup_start_date/backupinfo.txt
done

finish_date=$(date +%Y-%m-%d-%H%M%S)
echo "" >> $backup_folder/$backup_start_date/backupinfo.txt
echo "" >> $backup_folder/$backup_start_date/backupinfo.txt
echo "Backup complete! Finished at: $finish_date" >> $backup_folder/$backup_start_date/backupinfo.txt

# prepare for sshfs
chgrp -R backups $backup_folder/$backup_start_date
chmod -R 770 $backup_folder/$backup_start_date

# Get the size of the backup
backup_size=$(du -sh $backup_folder/$backup_start_date | awk '{print $1}')

# Convert the backup size to GB and MB
backup_size_gb=$(echo "scale=2; $backup_size / 1024" | awk '{printf "%.2f\n", $0}')
backup_size_mb=$(echo "scale=2; $backup_size % 1024" | awk '{printf "%.2f\n", $0}')

# Set the contents of the file under /etc/motdmanage/infofiles/backupstate/content.txt
echo "Latest backup: $finish_date. The backup started around $backup_start_date. The final size of the backup is ${backup_size_gb},${backup_size_mb}GB" > /etc/motdmanage/infofiles/backupstate/content.txt

