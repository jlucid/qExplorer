# qExplorer


# Download source code using GIT

```C++
git clone git@github.com:jlucid/qExplorer.git
```

# Set Configuration settings

Navigate to the config/settings.q file and set the mainDB and refDB file paths.
These paths will set the location where block data will be stored.
In addition, set the rpc username and password values to match those
in the bitcoin.conf file used by your locally running node

```C++
// Location of mainDB and refDB
// Locations need to be different

mainDB:`:.;
refDB:`:.; 

// Credentials for JSON RPC

rpcUsername:"";
rpcPassword:"";
```

# qUtil

The qExplorer assumes that your system already has the qutil library installed.

Once installed, create a soft link named "qExplorer" in your QPATH directory which points to the qExplorer/lib folder. This will enable standard .utl.require function to find the init.q file and load the library. The namespace contains all the supported API calls.

```C++
    q).utl.require "qExplorer"
```

# Run the process

```C++
    q)q qExplorer/app/qExplorer.q
```








