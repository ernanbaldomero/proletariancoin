#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

PROLETARIANCOIND=${PROLETARIANCOIND:-$SRCDIR/proletariancoind}
PROLETARIANCOINCLI=${PROLETARIANCOINCLI:-$SRCDIR/proletariancoin-cli}
PROLETARIANCOINTX=${PROLETARIANCOINTX:-$SRCDIR/proletariancoin-tx}
PROLETARIANCOINQT=${PROLETARIANCOINQT:-$SRCDIR/qt/proletariancoin-qt}

[ ! -x $PROLETARIANCOIND ] && echo "$PROLETARIANCOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
PRCVER=($($PROLETARIANCOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$PROLETARIANCOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $PROLETARIANCOIND $PROLETARIANCOINCLI $PROLETARIANCOINTX $PROLETARIANCOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${PRCVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${PRCVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m