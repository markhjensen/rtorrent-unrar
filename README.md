### Understanding the pipeline

    The intention is that some files are pacakged and some are note and this can be hard to deal with
    So the soluton is to configure a sorting script in bash to run on torrent completion to then be served in the same non-rar format for a sync folder or similar

    Your rtorrent client can additonally be configured to cleanuo/delete files and data at your desired time and intercal

    Using ruTorrent in ratio groups and example could be:
     - Min,%: 500 - When 5x of DL is UL
     - Max,%: 0 - No cap on UL in percentage
     - UL, MiB: 0 - No cap on UL in MiB
     - Time,h: 336 - 2 weeks of seed
     - Action: Remove data - Delete torrent and data
     Default ratio group = <your group id>
    
### Setup Instructions

1. **Get the Script**:

    Create a `script` directory `mkdir script` in your desired location (typically home/script)

    You can obtain the script by either using `wget` or `git`:
    ```bash
    # Using wget
    wget https://example.com/path/to/rtorrent-complete.sh
    
    # Using git
    git clone https://github.com/example/repository.git
    ```

2. **Edit `.rtorrent.rc`**:

    Modify your `.rtorrent.rc` (typically found in home) configuration file with the following settings:
    ```bash
    # Set the session directory (where rtorrent stores its session data)
    session = ~/.config/rtorrent/session

    # Enable logging
    log.open_file = ~/.config/rtorrent/log.txt

    # Set up method to execute script on download completion
    method.set_key = event.download.finished,complete,"execute.throw.bg=home/scripts/rtorrent-complete.sh"
    ```

3. **Test Script Execution**:

    You have two options to test the script:

    - Option 1: Directly call `rtorrent-complete.sh` with the path to a single file:
        ```bash
        # Example usage
        sh rtorrent-complete.sh /path/to/file
        ```

    - Option 2: Use the provided test script to run the main script in parallel for all files in a folder:
        ```bash
        #!/bin/bash

        # Loop through all files in the data directory
        for object in ../private/rtorrent/data/*; do
            # Execute the script for each file
            sh rtorrent-complete.sh "$object" &
        done
        ```


