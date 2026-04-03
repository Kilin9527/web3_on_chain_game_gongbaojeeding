/**
 * Program IDL in camelCase format in order to be used in JS/TS.
 *
 * Note that this is only a type helper and is not the actual IDL. The original
 * IDL can be found at `target/idl/text_based_game.json`.
 */
export type TextBasedGame = {
  "address": "BGQP5xC8dFX8KyDXSWdBBm5g8sVAYfg2ESPrChxyoBqt",
  "metadata": {
    "name": "textBasedGame",
    "version": "0.1.0",
    "spec": "0.1.0",
    "description": "Created with Anchor"
  },
  "instructions": [
    {
      "name": "acceptAdmin",
      "discriminator": [
        112,
        42,
        45,
        90,
        116,
        181,
        13,
        170
      ],
      "accounts": [
        {
          "name": "config",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  67,
                  111,
                  110,
                  102,
                  105,
                  103
                ]
              }
            ]
          }
        },
        {
          "name": "newAdmin",
          "writable": true,
          "signer": true
        }
      ],
      "args": []
    },
    {
      "name": "initialize",
      "discriminator": [
        175,
        175,
        109,
        31,
        13,
        152,
        155,
        237
      ],
      "accounts": [
        {
          "name": "signer",
          "writable": true,
          "signer": true
        },
        {
          "name": "pda",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  117,
                  115,
                  101,
                  114
                ]
              },
              {
                "kind": "account",
                "path": "signer"
              }
            ]
          }
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "name",
          "type": "string"
        }
      ]
    },
    {
      "name": "initializeConfig",
      "discriminator": [
        208,
        127,
        21,
        1,
        194,
        190,
        196,
        70
      ],
      "accounts": [
        {
          "name": "config",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  67,
                  111,
                  110,
                  102,
                  105,
                  103
                ]
              }
            ]
          }
        },
        {
          "name": "admin",
          "writable": true,
          "signer": true,
          "address": "3iyS9TmCgCFCisUjjnKN1hQEVDhXFrk2b5X5cg9M92gi"
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "cid",
          "type": "string"
        }
      ]
    },
    {
      "name": "initializeMintConfig",
      "discriminator": [
        61,
        141,
        161,
        167,
        9,
        153,
        85,
        170
      ],
      "accounts": [
        {
          "name": "backendConfig",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  109,
                  105,
                  110,
                  116,
                  95,
                  99,
                  111,
                  110,
                  102,
                  105,
                  103
                ]
              }
            ]
          }
        },
        {
          "name": "mintAuthorityPda",
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  109,
                  105,
                  110,
                  116,
                  95,
                  103,
                  111,
                  108,
                  100,
                  95,
                  97,
                  117,
                  116,
                  104
                ]
              }
            ]
          }
        },
        {
          "name": "admin",
          "writable": true,
          "signer": true,
          "address": "3iyS9TmCgCFCisUjjnKN1hQEVDhXFrk2b5X5cg9M92gi"
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "backendPubkey",
          "type": "pubkey"
        }
      ]
    },
    {
      "name": "proposeAdmin",
      "discriminator": [
        121,
        214,
        199,
        212,
        87,
        39,
        117,
        234
      ],
      "accounts": [
        {
          "name": "config",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  67,
                  111,
                  110,
                  102,
                  105,
                  103
                ]
              }
            ]
          }
        },
        {
          "name": "admin",
          "signer": true,
          "relations": [
            "config"
          ]
        },
        {
          "name": "newAdmin",
          "docs": [
            "The account doesn't need to sign here, and it can be any valid Solana address",
            "(System Account, PDA, Multisig, etc.).",
            "Verification happens in the `accept_admin` step."
          ]
        }
      ],
      "args": []
    },
    {
      "name": "updateConfig",
      "discriminator": [
        29,
        158,
        252,
        191,
        10,
        83,
        219,
        99
      ],
      "accounts": [
        {
          "name": "config",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  67,
                  111,
                  110,
                  102,
                  105,
                  103
                ]
              }
            ]
          }
        },
        {
          "name": "admin",
          "signer": true,
          "relations": [
            "config"
          ]
        }
      ],
      "args": [
        {
          "name": "cid",
          "type": "string"
        }
      ]
    },
    {
      "name": "updateExp",
      "discriminator": [
        236,
        173,
        237,
        81,
        12,
        66,
        235,
        15
      ],
      "accounts": [
        {
          "name": "signer",
          "writable": true,
          "signer": true
        },
        {
          "name": "pda",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  117,
                  115,
                  101,
                  114,
                  95,
                  101,
                  120,
                  112
                ]
              },
              {
                "kind": "account",
                "path": "signer"
              }
            ]
          }
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "exp",
          "type": "u32"
        }
      ]
    },
    {
      "name": "updateGold",
      "discriminator": [
        136,
        99,
        246,
        33,
        169,
        102,
        51,
        172
      ],
      "accounts": [
        {
          "name": "signer",
          "writable": true,
          "signer": true
        },
        {
          "name": "pda",
          "writable": true,
          "pda": {
            "seeds": [
              {
                "kind": "const",
                "value": [
                  117,
                  115,
                  101,
                  114,
                  95,
                  103,
                  111,
                  108,
                  100
                ]
              },
              {
                "kind": "account",
                "path": "signer"
              }
            ]
          }
        },
        {
          "name": "systemProgram",
          "address": "11111111111111111111111111111111"
        }
      ],
      "args": [
        {
          "name": "gold",
          "type": "i32"
        }
      ]
    }
  ],
  "accounts": [
    {
      "name": "backendConfig",
      "discriminator": [
        224,
        68,
        245,
        27,
        117,
        207,
        210,
        158
      ]
    },
    {
      "name": "config",
      "discriminator": [
        155,
        12,
        170,
        224,
        30,
        250,
        204,
        130
      ]
    },
    {
      "name": "user",
      "discriminator": [
        159,
        117,
        95,
        227,
        239,
        151,
        58,
        236
      ]
    }
  ],
  "errors": [
    {
      "code": 6000,
      "name": "userNameTooShort",
      "msg": "User name is too short."
    },
    {
      "code": 6001,
      "name": "userNameTooLong",
      "msg": "User name is too long."
    },
    {
      "code": 6002,
      "name": "unauthorizedAccount",
      "msg": "Unauthorized account."
    },
    {
      "code": 6003,
      "name": "goldOverflow",
      "msg": "Your gold is overflow."
    },
    {
      "code": 6004,
      "name": "goldNotEnough",
      "msg": "Your gold is not enough."
    },
    {
      "code": 6005,
      "name": "expOverflow",
      "msg": "Your experience is overflow."
    },
    {
      "code": 6006,
      "name": "initialConfigMappingFailed",
      "msg": "Failed to initialize config_mapping."
    },
    {
      "code": 6007,
      "name": "transferConfigAdminFailed",
      "msg": "Failed to transfer config admin."
    },
    {
      "code": 6008,
      "name": "invalidAdminChange",
      "msg": "Invalid admin change."
    },
    {
      "code": 6009,
      "name": "invalidMintAuthority",
      "msg": "Invalid mint authority."
    }
  ],
  "types": [
    {
      "name": "backendConfig",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "backendPubkey",
            "type": "pubkey"
          },
          {
            "name": "admin",
            "type": "pubkey"
          },
          {
            "name": "mintAuthBump",
            "type": "u8"
          }
        ]
      }
    },
    {
      "name": "config",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "admin",
            "type": "pubkey"
          },
          {
            "name": "pendingAdmin",
            "type": {
              "option": "pubkey"
            }
          },
          {
            "name": "configCid",
            "type": "string"
          }
        ]
      }
    },
    {
      "name": "user",
      "type": {
        "kind": "struct",
        "fields": [
          {
            "name": "exp",
            "type": "u32"
          },
          {
            "name": "gold",
            "type": "i32"
          },
          {
            "name": "bump",
            "type": "u8"
          },
          {
            "name": "name",
            "type": "string"
          },
          {
            "name": "authority",
            "type": "pubkey"
          }
        ]
      }
    }
  ],
  "constants": [
    {
      "name": "config",
      "type": "bytes",
      "value": "[67, 111, 110, 102, 105, 103]"
    },
    {
      "name": "genesisAdmin",
      "type": "pubkey",
      "value": "3iyS9TmCgCFCisUjjnKN1hQEVDhXFrk2b5X5cg9M92gi"
    },
    {
      "name": "mintConfig",
      "type": "bytes",
      "value": "[109, 105, 110, 116, 95, 99, 111, 110, 102, 105, 103]"
    },
    {
      "name": "mintGoldAuth",
      "type": "bytes",
      "value": "[109, 105, 110, 116, 95, 103, 111, 108, 100, 95, 97, 117, 116, 104]"
    },
    {
      "name": "user",
      "type": "bytes",
      "value": "[117, 115, 101, 114]"
    },
    {
      "name": "userExp",
      "type": "bytes",
      "value": "[117, 115, 101, 114, 95, 101, 120, 112]"
    },
    {
      "name": "userGold",
      "type": "bytes",
      "value": "[117, 115, 101, 114, 95, 103, 111, 108, 100]"
    }
  ]
};
