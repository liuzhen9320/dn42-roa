# dn42-roa
基于公网 AS-SET 的 DN42 ROA 自动化

## 快速上手

BIRD 中应使用 Route Origin Authorizations 来验证前缀通告。这些检查原始 AS 并验证它们是否有权发布前缀。

```
protocol static {
    roa4 { table dn42_roa; };
    include "/etc/bird/roa_dn42.conf";
};

protocol static {
    roa6 { table dn42_roa_v6; };
    include "/etc/bird/roa_dn42_v6.conf";
};
```

您可以将 cron 条目添加到定期更新表中：

```
*/15 * * * * curl -sfSLR {-o,-z}/etc/bird/roa_dn42.conf https://raw.githubusercontent.com/liuzhen9320/dn42-roa/refs/heads/main/conf/dn42_roa_as213891-as-wyfix-member-dn42_4.conf && birdc configure > /dev/null
*/15 * * * * curl -sfSLR {-o,-z}/etc/bird/roa_dn42_v6.conf https://raw.githubusercontent.com/liuzhen9320/dn42-roa/refs/heads/main/conf/dn42_roa_as213891-as-wyfix-member-dn42_6.conf && birdc configure > /dev/null
```
