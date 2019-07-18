# PoolTogether Double Winner Calculation

After PoolTogether was launched, a flaw was discovered in the smart contracts.  The flaw lead to there being two winners.  It is explained in more detail in the [article here](https://medium.com/pooltogether/randomness-selection-vulnerability-in-pool-2-9fb328688680).

Because the "true" winner was lost over time, this contract re-creates the selection state in order to calculate the true winner of the pool.

The broken Pool in question is located at [0x4Fc604536134Dc64718800361eCbca0df6cBfE08](https://etherscan.io/address/0x4Fc604536134Dc64718800361eCbca0df6cBfE08).  You'll notice under the read contract section it lists the winner as being `0xbF63f97613f796E1dE3446e64b529C79E5cc40b2`.  This winner was calculated incorrectly, as far as we intended.  The true winner we intended is `0x2A1049062c6Cfd69bd38fbaf3b0559DF1DBbc92c`.  You can calculate it yourself using the instructions below.

# Setup

Clone the repo and then install deps:

```
$ yarn
```

Copy over .envrc and allow [direnv](https://direnv.net/):

```
$ cp .envrc.example .envrc
$ direnv allow
```

Start `ganache-cli`:

```
$ yarn start
```

Note: if you changed the mnemonic, you should update the ADMIN_ADDRESS variable in `.envrc` with another address (I use the second address listed when `ganache-cli` starts).

Now start a new zos session:

```
$ yarn session
```

Push out the local contracts:

```
$ zos push
```

Migrate the contracts and bootstrap the data:

```
$ yarn migrate
```

To see what data is bootstrapped, have a look at the migrations.

# Verifying

Once the migrations are complete, you'll notice the last two output lines are the true winner and the false winner.  The true winner will receive the correct funds.