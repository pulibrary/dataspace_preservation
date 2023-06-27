# DataSpace Preservation Workflows

This repository contains scripts and documentation for backing up objects from DataSpace into separate storage, utilizing DSpace export and Python-based BagIt packaging workflows.

## Resources 
* [Older documentation](https://docs.google.com/document/d/1Io6V34ft__acYTX6uMZQO-8zJy5EX-qXLiUwgGmREsk/edit)

## Requirements
* Ruby 
* Python
* pipenv
* rsync 
* tar

## Setup

1. Install requirements.
   1. clone this repo `git clone git@github.com:pulibrary/dataspace_preservation.git`
   1. Also clone dspace-python `git clone git@github.com:pulibrary/dspace-python.git`

## Instructions

1. cd into the dataspace_preservation directory
1. Install gems via bundler `bundle install`
1. If you are backing up a collection that is not under the Senior Theses community, run `list_arks.rb` as follows to output a list of arks that can be used to create a manifest as follows (arguments supplied are examples):
   ```bash 
   bundle exec ruby list_arks.rb -h https://dataspace-staging.princeton.edu -a ark:/88435/dsp01zw12z7787
   ```
    You should see output something like the following: 
    ```bash 
    88435/dsp01d791sj97j
    88435/dsp01v405sc863
    ```
1. If you are backing up Senior Theses, run `list_arks.rb` and supply a class year as a command line argument, to output a list of arks that can be used to create a manifest as follows (arguments supplied are examples):
   ```bash 
   bundle exec ruby list_arks.rb -h https://dataspace-staging.princeton.edu -a ark:/88435/dsp01sf268516n -c 2019
   ```
    You should see output something like the following: 
    ```bash 
    88435/dsp014m90dz32m
    88435/dsp01mp48sg59q
    88435/dsp01gx41mm67g
    88435/dsp017d278w83s
    88435/dsp01w66346442
    ...
    ```
1. Pipe the list_arks output to a manifest file, examples:
   ```bash 
   bundle exec ruby list_arks.rb -h https://dataspace-staging.princeton.edu -a ark:/88435/dsp01zw12z7787 > manifest
   ```

   or 

   ```bash 
   bundle exec ruby list_arks.rb -h https://dataspace-staging.princeton.edu -a ark:/88435/dsp01sf268516n -c 2019 > manifest
   ```
1. Transfer the manifest to the DataSpace server. (consult RDSS team if you need help with the ssh configuration information)
   * for staging
     ```bash
     scp manifest pulsys@gcp_dataspace_staging1:.
     ```
   * for prod
     ```bash
     scp manifest pulsys@gcp_dataspace_prod1:.
     ```
1. SSH to the appropriate DataSpace server (staging or production).
   1. Become the dspace user
   1. Create a directory on the server where your exports will be stored temporarily.
   1. get the export from dataspace script
      ```bash
      wget https://github.com/pulibrary/dataspace_preservation/blob/main/export_from_dspace.sh
      ```
   1. run it with the manifest and exports directory as command line arguments, example:
      ```bash 
      ./export_from_dspace.sh manifest exports_directory
      ```
   1. tar and zip the data
      ```bash
      tar -cvf ~pulsys/exports_directory.tar exports_directory
      gzip ~pulsys/exports_directory.tar.gz
      ```
1. Locally, using rsync or something similar, copy the files down from the server to local storage. for example
   ```bash
   scp pulsys@gcp_dataspace_prod1:exports_directory.tar.gz .
   ```
   
1. cd to the dspace-python project directory and run the commands from [the README](https://github.com/pulibrary/dspace-python#installing-the-python-package-dependencies)
1. Run the BagIt code from [dspace-python](https://github.com/pulibrary/dspace-python) as follows:
    ```bash
    python bagit-python/bagit.py ../dataspace_preservation/exports_directory/2019_theses
    ```
    Where `exports_directory/2019_theses` is an example of the value of the path to the local copy of the DSpace exports directory that you populated with the rsync command above.
1. Inspect the exports directory.  It should look something like the following: 
    ```bash
    ls -la exports/2019_theses
    bag-info.txt
    bagit.txt
    data/
    manifest-sha256.txt
    manifest-sha512.txt
    tagmanifest-sha256.txt
    tagmanifest-sha512.txt
    ```
    Note that the `data/` directory should contain all of the exported DSpace object directories.
1. Compress the bag directory as follows:
    ```bash 
    tar -czf  2019_theses.tgz 2019_theses
    ```
1. Transfer the compressed backups to remote storage.
