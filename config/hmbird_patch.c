// SPDX-License-Identifier: GPL-2.0
/*
 * hmbird_patch.c — HMBird Performance Framework Bypass
 *
 * Xiaomi HyperOS 的 HMBird 框架会检测内核签名，
 * 对未认证的内核限制 CPU/GPU 性能调度。
 * 本模块注入空实现，绕过该检测，保持完整性能释放。
 *
 * 适用：Xiaomi 17 Ultra (popsicle) / HyperOS / GKI 6.12
 */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/proc_fs.h>
#include <linux/seq_file.h>

/* HMBird 期望从 /proc/hmbird/version 读取版本号 */
static int hmbird_version_show(struct seq_file *m, void *v)
{
	seq_printf(m, "2.0\n");
	return 0;
}

static int hmbird_version_open(struct inode *inode, struct file *file)
{
	return single_open(file, hmbird_version_show, NULL);
}

static const struct proc_ops hmbird_version_fops = {
	.proc_open    = hmbird_version_open,
	.proc_read    = seq_read,
	.proc_lseek   = seq_lseek,
	.proc_release = single_release,
};

static int __init hmbird_patch_init(void)
{
	struct proc_dir_entry *dir, *entry;

	dir = proc_mkdir("hmbird", NULL);
	if (!dir) {
		pr_warn("hmbird_patch: 创建 /proc/hmbird 失败，继续运行\n");
		return 0;
	}

	entry = proc_create("version", 0444, dir, &hmbird_version_fops);
	if (!entry)
		pr_warn("hmbird_patch: 创建 version 节点失败\n");

	pr_info("hmbird_patch: HMBird bypass 已加载\n");
	return 0;
}

static void __exit hmbird_patch_exit(void)
{
	remove_proc_entry("version", NULL);
	remove_proc_entry("hmbird", NULL);
}

module_init(hmbird_patch_init);
module_exit(hmbird_patch_exit);

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("ski-17ultra project");
MODULE_DESCRIPTION("HMBird Performance Framework Bypass for Xiaomi 17 Ultra");
